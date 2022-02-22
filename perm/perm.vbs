' cscript //Nologo perm.vbs > a.txt
' sort /unique a.txt > b.txt

Option Explicit

Sub perm(dst, src)
	Dim i
	If Len(src) = 0 Then
		WScript.Echo(dst)
		Exit Sub
	End If
	For i = 1 To Len(src)
		perm dst & Mid(src, i, 1), Left(src, i-1) & Mid(src, i+1)
	Next
End Sub

perm "", "GAKKOU"
