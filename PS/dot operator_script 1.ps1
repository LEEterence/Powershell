Clear-Host       

$funny = "laughing"

$scriptpath = split-path -parent $MyInvocation.MyCommand.Definition
$filename = "dot operator_script 2.ps1"

"Example 1:" # Call another script. Variables are passed only forward.

& $scriptpath\$filename

"Example 2:" # Call another script. Variables are passed backwards and forwards.

. $scriptpath\$filename
$variableDefinedInOtherScript