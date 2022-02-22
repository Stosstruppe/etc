# permutation
function perm($dst, $src) {
	if ($src.Length -eq 0) {
		Write-Output $dst
		return
	}
	for ($i = 0; $i -lt $src.Length; $i++) {
		perm ($dst + $src.Substring($i, 1)) $src.Remove($i, 1)
	}
}
perm "" "GAKKOU" > a.txt
sort.exe /unique a.txt > b.txt
