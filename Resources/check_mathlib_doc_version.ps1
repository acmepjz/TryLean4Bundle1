try {
	$A = Select-String -Pattern 'leanprover-community/mathlib4/blob/([0-9a-f]+)/' -Path .\Mathlib\Data\Nat\Notation.html
	$A = $A[0].Matches[0].Groups[1].Value
	Out-File -FilePath .\doc_version.txt -InputObject $A -Encoding ascii
	try {
		$B = & gh api "/repos/leanprover-community/mathlib4/commits/$A" --jq ".commit.author.date"
		Out-File -FilePath .\doc_version.txt -Append -InputObject $B -Encoding ascii
	} catch {
		Write-Host "::warning::failed to get git commit time from git commit hash (gh not installed?)"
	}
} catch {
	Write-Host "::warning::failed to get mathlib doc version"
	Out-File -FilePath .\doc_version.txt -InputObject "unknown" -Encoding ascii
}
