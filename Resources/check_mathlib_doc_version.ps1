function Get-RemoteCommitTime {
	param(
		[Parameter(Mandatory=$true)]
		[string]$RemoteUrl,

		[Parameter(Mandatory=$true)]
		[string]$CommitHash,

		[ValidateSet('iso', 'iso-strict', 'rfc', 'short', 'raw', 'unix', 'relative')]
		[string]$DateFormat = 'iso'
	)

	# Create unique temporary directory
	$tempGuid = [System.Guid]::NewGuid().ToString().Substring(0, 8)
	$tempDir = Join-Path $env:TEMP "git-check-$tempGuid"

	try {
		# Create temporary directory
		New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

		# Use Push-Location/Pop-Location to ensure we return to original directory
		Push-Location $tempDir

		# Initialize git repo
		git init --quiet

		# Add remote and fetch specific commit
		git remote add origin $RemoteUrl
		$fetchResult = git fetch origin $CommitHash 2>&1

		# Check if fetch was successful
		if ($LASTEXITCODE -ne 0) {
			throw "Failed to fetch commit $CommitHash from $RemoteUrl. Error: $fetchResult"
		}

		# Get commit time in requested format
		$commitTime = git log -1 --format="%ad" --date=$DateFormat FETCH_HEAD

		# Create output object
		[PSCustomObject]@{
			CommitHash = $CommitHash
			RemoteUrl = $RemoteUrl
			CommitTime = $commitTime
			DateFormat = $DateFormat
		}

	} catch {
		Write-Error "Error getting commit time: $_"
		return $null
	} finally {
		# Return to original directory
		Pop-Location

		# Cleanup temporary directory
		if (Test-Path $tempDir) {
			Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
		}
	}
}

try {
	$A = Select-String -Pattern 'leanprover-community/mathlib4/blob/([0-9a-f]+)/' -Path .\Mathlib\Data\Nat\Notation.html
	$A = $A[0].Matches[0].Groups[1].Value
	Out-File -FilePath .\doc_version.txt -InputObject $A -Encoding ascii
	try {
		$Response = Get-RemoteCommitTime -RemoteUrl "https://github.com/leanprover-community/mathlib4.git" -CommitHash "$A"
		$B = $Response.CommitTime
		Out-File -FilePath .\doc_version.txt -Append -InputObject $B -Encoding ascii
	} catch {
		Write-Host "::warning::failed to get git commit time from git commit hash"
	}
} catch {
	Write-Host "::warning::failed to get mathlib doc version"
	Out-File -FilePath .\doc_version.txt -InputObject "unknown" -Encoding ascii
}
