#requires -version 2
<#
.SYNOPSIS
  file2url.ps1
.DESCRIPTION
  Converts a [fullpath]name (file or folder) into a file url and places it into the clipboard.
  - it can be used from TotalCommander
  - it can be used for Confluence (#encoding: Windows 1250 (important for the umlaute!))
.PARAMETER pInputFilename
  The filename or the fullpathname of a file or directory.
.PARAMETER pWriteDebug
  no/yes-Parameter for writing debugs. 
  The PowerShell.exe has got different params for debug!
.PARAMETER pForCnfl
  no/yes-Parameter for being used for Confluence or not. In Confluence file url cannot be any space, hyphen, umlaut!
.INPUTS
  See Parameters.
.OUTPUTS
  file url in the system clipboard.
.NOTES
  Version:        1.0
  Author:         swiit Számítástechnikai és Iparmûvészeti Kft. / Árpád Szilágyi
  Creation Date:  08.03.2020
  Purpose/Change: Initial script development.
.EXAMPLE
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

.USAGE TotalCommander without Debug
  Command...: PowerShell.exe -executionpolicy bypass -WindowStyle Hidden -File <path>\file2url.ps1
  Parameters: %P%S -pWriteDebug "no" -pForCnfl "yes"
  Start Path: d:\tmp
  Tooltip...: DEBUG=FALSE - Converts full path name of selected file to file url for Confluence.

.USAGE TotalCommander with Debug
  Command...: PowerShell.exe -executionpolicy bypass -noexit             -File <path>\file2url.ps1
  Parameters: %P%S -pWriteDebug "yes" -pForCnfl "yes"
  Start Path: d:\tmp
  Tooltip...: DEBUG=TRUE - Converts full path name of selected file to file url for Confluence.

.KNOWHOW  
  $colors = [enum]::GetValues([System.ConsoleColor])

  Foreach ($bgcolor in $colors){
    Foreach ($fgcolor in $colors) { Write-Host "$fgcolor|"  -ForegroundColor $fgcolor -BackgroundColor $bgcolor -NoNewLine }
    Write-Host " on $bgcolor"
  }

  Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White
#>

#
#parameter (optional) for the script (--> TotalCommander %P%N : fullpathname)
#
#param([string]$pInputFilename = "c:\helloworld\foo.txt")
param
( [string]$pInputFilename = "c:\helloworld\foo-invalid.txt"
, [string]$pWriteDebug = "no"
, [string]$pForCnfl = "no"
)

#------------------------------------------------------------------------------
# filtering chars in fullpathname for confluence (cnfl)
#
if ($pForCnfl -ieq "no") { #-ieq: case insensitive comparison
  $script:cnfl = $false;
} else {
  $script:cnfl = $true;
}
#flags for illegal chars for cnfl
$script:illegal=$false;
$script:space=$false;
$script:hyphen=$false;
$script:umlaut=$false;

#------------------------------------------------------------------------------
# for debug there is an other parameterlist for PowerShell.exe!
#
if ($pWriteDebug -ieq "no") { #-ieq: case insensitive comparison
  $script:debug = $false;
} else {
  $script:debug = $true;
}
#variables for the debug-Write-Host
$script:whLen=20
$script:whChar='.'

#
# simple debug-Write-Host function with title and value for padding
#
function WrDebug () {
  Param
  ( [string] $title
  , [string] $value
  , [string] $color="none" #optional color for the debug-output (yellow is default, otherwise red...)
  )
  if ($script:debug) {
    if ($color -eq "none") {
      # Write-Host "wh: $title".PadRight($script:whLen,$script:whChar)"="$value;
      Write-Host -ForegroundColor "Yellow"   "[dbg] $title".PadRight($script:whLen,$script:whChar)"="$value; 
    } elseif ($color = "DarkCyan") {
      Write-Host -ForegroundColor "DarkCyan" "[dbg] $title".PadRight($script:whLen,$script:whChar)"="$value; 
    } else {
      Write-Host -ForegroundColor "Red"      "[dbg] $title".PadRight($script:whLen,$script:whChar)"="$value; 
    }
  }
}
  
#------------------------------------------------------------------------------
#parameters
#
WrDebug  "pInputFilename" "$pInputFilename" "DarkCyan"
WrDebug  "pWriteDebug" "$pWriteDebug" "DarkCyan"
WrDebug  "pForCnfl" "$pForCnfl" "DarkCyan"

#------------------------------------------------------------------------------
# fullpathname (?) as parameter
#
$script:ix=$pInputFilename.IndexOf(":")
if ($script:ix -eq -1) { 
  # -1: there is no ":" in pInputFilename

  # get and write out the working directory
  # $script:pwd=(Get-Item -Path '.\' -Verbose).FullName
  $script:pwd=$pwd
  WrDebug  "pwd" "$script:pwd" "DarkCyan"

  $script:inputfilename="$script:pwd\$pInputFilename";
  WrDebug  "inputfilename" "$inputfilename" "DarkCyan"
} else {
  $script:inputfilename=$pInputFilename;
}

#
#lists the calling params of the script --> $args cannot be read here! why? i don't know...
#
# if ($script:debug) {
#   WrDebug "args.count" $args.count;
#   WrDebug "args.Length" $args.Length;
#   foreach ($arg in $args)
#   {
#     WrDebug "args" $arg;
#   }
# }

#
#
#
function Get-ClipBoard {
    Add-Type -AssemblyName System.Windows.Forms
    $tb = New-Object System.Windows.Forms.TextBox
    $tb.Multiline = $true
    $tb.Paste()
    $tb.Text
}

#
#
#
function Set-ClipBoard() {
    Param(
      [Parameter(ValueFromPipeline=$true)]
      [string] $text
    )
    Add-Type -AssemblyName System.Windows.Forms
    $tb = New-Object System.Windows.Forms.TextBox
    $tb.Multiline = $true
    $tb.Text = $text
    $tb.SelectAll()
    $tb.Copy()
}

#check if the fullpathname contains space,hyphen or umlaut...

$txt=$script:inputfilename;
WrDebug "txt (before)" $txt

if ($script:cnfl) {
  if (-not $script:illegal) {
    $txt = $txt.Replace(" ","@");
    if ($txt -ne $inputfilename) {
      $script:illegal=$true;
      $script:space=$true;
    }
  }
  if (-not $script:illegal) {
    $txt = $txt.Replace("-","@");
    if ($txt -ne $inputfilename) {
      $script:illegal=$true;
      $script:hyphen=$true;
    }
  }
  if (-not $script:illegal) {
    $txt = $txt.Replace("ä","x").Replace("Ä","x").Replace("ö","x").Replace("Ö","x").Replace("ß","x");
    if ($txt -ne $inputfilename) {
      $script:illegal=$true;
      $script:umlaut=$true;
    }
  }
}
WrDebug "txt (after)" $txt

if ($script:illegal) {
  #the fullpathname is not ok, it contains spaces or hyphens or umlauts etc.
  if ($script:space) {
    $charType="space";
  } elseif ($script:hyphen) {
    $charType="hyphen";
  } elseif ($script:umlaut) {
    $charType="umlaut";
  }
  $url = "Caution! Illegal $charType for Confluence!"
  
  Write-Host -ForegroundColor "yellow" $inputfilename
  Write-Host -ForegroundColor "Red" $url
}
else {
  #the fullpathname is ok, it doesn't contain any spaces, hyphens, etc.
  $url = "file:///" + $inputfilename -Replace "\\", "/"

  Write-Host -ForegroundColor "yellow" $inputfilename
  Write-Host -ForegroundColor "Green" $url
}
Set-ClipBoard("$url");

if ($script:debug) {
  #stops the console, to be able to check the written debug-information
  pause
}
