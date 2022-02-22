/*
cscript //Nologo perm.js > a.txt
sort /unique a.txt > b.txt
*/

function perm(dst, src) {
	if (src.length == 0) {
		WScript.Echo(dst);
		return;
	}
	for (var i = 0; i < src.length; i++) {
		perm(dst + src.substr(i, 1), src.substr(0, i) + src.substr(i+1));
	}
}

perm("", "GAKKOU");
