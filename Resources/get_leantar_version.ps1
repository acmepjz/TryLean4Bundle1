try {
	$A = (Get-Content -Path .\IO.lean -Raw) -replace "`r`n|`n", " "
	$A = Select-String -Pattern 'LEANTARVERSION\s*:=\s*"([^"]*)"' -InputObject $A
	$A = $A[0].Matches[0].Groups[1].Value
	Write-Host "get leantar version $A"
	Out-File -FilePath .\leantar_version.txt -InputObject $A -Encoding ascii
} catch {
	$A = "0.1.16"
	Write-Host "::warning::failed to get leantar version, use default value $A"
	Out-File -FilePath .\leantar_version.txt -InputObject $A -Encoding ascii
}
