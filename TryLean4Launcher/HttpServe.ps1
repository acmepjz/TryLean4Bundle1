Add-Type -AssemblyName System.Web
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Zip file
$zipFileName = "doc.zip"

try {
    $zipFile = [System.IO.Compression.ZipFile]::OpenRead($zipFileName)
} catch {
    write-host ("ERROR: failed to open file '{0}'!" -f $zipFileName) -f 'red'
    exit 1
}

Function Check-FileExistsInZip {
    param (
        [string]$FileName
    )
    try {
        $entry = $zipFile.GetEntry($FileName)
        Return ($entry -ne $null)
    } catch {
        Return $false
    }
}

# Http Server
$http = [System.Net.HttpListener]::new()

# Hostname and port to listen on
$http.Prefixes.Add("http://127.0.0.1:13480/")

# Start the Http Server
$http.Start()

# Log ready message to terminal
if ($http.IsListening) {
    write-host " HTTP Server Ready!  " -f 'black' -b 'gre'
} else {
    write-host "ERROR: failed to start HTTP server!" -f 'red'
    exit 1
}

try {
    while ($http.IsListening) {
        $contextTask = $http.GetContextAsync()
        while (-not $contextTask.AsyncWaitHandle.WaitOne(200)) { }
        $context = $contextTask.GetAwaiter().GetResult()

        if ($context.Request.HttpMethod -ne 'GET') {
            $context.Response.StatusCode = 405
            $context.Response.ContentLength64 = 0
            $context.Response.OutputStream.Close()
        } else {
            # log the request to the terminal
            write-host "GET $($context.Request.RawUrl)" -f 'mag'

            [string]$path = $context.Request.RawUrl

            # Normalize path to ensure no backslashes and no double slashes
            $path = $path.Replace("\", "/")
            while ($path.Contains("//")) {
                $path = $path.Replace("//", "/")
            }

            if ($path.EndsWith("/")) {
                $path = $path + "index.html"
            }

            $path = $path.TrimStart("/")

            if (Check-FileExistsInZip ($path + ".br")) {
                $pathInZip = $path + ".br"
                $contentEncoding = "br"
                $statusCode = 200
            } elseif (Check-FileExistsInZip $path) {
                $pathInZip = $path
                $contentEncoding = $null
                $statusCode = 200
            } elseif (-Not $path.EndsWith("/")) {
                $exists = Check-FileExistsInZip ($path + "/index.html.br")
                $exists2 = Check-FileExistsInZip ($path + "/index.html")
                $newPath = "/" + $path + "/"
                $statusCode = if ($exists -Or $exists2) { 301 } else { 404 }
            }

            if ($statusCode -eq 200) {
                $entry = $zipFile.GetEntry($pathInZip)
                $stream = $entry.Open()

                # resposed to the request
                $context.Response.Headers.Set("Content-Type", [System.Web.MimeMapping]::GetMimeMapping($path))
                if ($contentEncoding -ne $null) {
                    $context.Response.Headers.Set("Content-Encoding", $contentEncoding)
                }
                $context.Response.Headers.Set("Cache-Control", "public, max-age=3600")
                $context.Response.ContentLength64 = $entry.Length
                $stream.CopyTo($context.Response.OutputStream) # stream to broswer
                $stream.Close()
                $context.Response.OutputStream.Close() # close the response
            } elseif ($statusCode -eq 301) {
                # log the request to the terminal
                write-host "301 $newPath" -f 'red'

                $context.Response.StatusCode = 301
                $context.Response.Headers.Set("Location", $newPath)
                $context.Response.ContentLength64 = 0
                $context.Response.OutputStream.Close()
            } else {
                # log the request to the terminal
                write-host "404" -f 'red'

                # the html/data
                [string]$html = ("<h1>404 Not Found</h1><p>The page <code>{0}</code> is not found on this server.</p>" -f [System.Web.HttpUtility]::HtmlEncode($context.Request.RawUrl))

                #resposed to the request
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
                $context.Response.StatusCode = 404
                $context.Response.ContentLength64 = $buffer.Length
                $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
                $context.Response.OutputStream.Close()
            }
        }
    }
} finally {
    # This is always called when ctrl+c is used
    $http.Stop()
    write-host " HTTP Server Stopped!  " -f 'black' -b 'gre'
    exit 0
}

exit 0
