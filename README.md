# file2url
Converts a [fullpath]name (file or folder) into a file url and places it into the clipboard.

Testcalls (for VS Code with PowerShell:Run selection [F8]; the working dir is the project manager dir!)
  --without debug
    PowerShell.exe -noexit -executionpolicy bypass -File file2url.ps1 file2urlTest-Nok.txt -pWriteDebug "no" -pForCnfl "yes"
    PowerShell.exe -noexit -executionpolicy bypass -File file2url.ps1 file2urlTestäNok.txt -pWriteDebug "no" -pForCnfl "yes"
    PowerShell.exe -noexit -executionpolicy bypass -File file2url.ps1 file2urlTestäNok.txt -pWriteDebug "no" -pForCnfl "no"
    PowerShell.exe -noexit -executionpolicy bypass -File file2url.ps1 file2urlTestOk.txt   -pWriteDebug "no" -pForCnfl "yes"
  --with debug
    PowerShell.exe -noexit -executionpolicy bypass -File file2url.ps1 file2urlTest-Nok.txt -pWriteDebug "yes" -pForCnfl "yes"
    PowerShell.exe -noexit -executionpolicy bypass -File file2url.ps1 file2urlTestäNok.txt -pWriteDebug "yes" -pForCnfl "yes"
    PowerShell.exe -noexit -executionpolicy bypass -File file2url.ps1 file2urlTestOk.txt -pWriteDebug "yes" -pForCnfl "yes"
