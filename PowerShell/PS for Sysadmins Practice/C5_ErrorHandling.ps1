#~ Code on how to handle errors
$fileLocation = "E:\_Git\Powershell\"

<# try {
    $files = Get-ChildItem -Path $fileLocation -ErrorAction Continue
    $files.foreach({
        $filetext = Get-Content $files
        $filetext[0]
    })
}
catch {
    $_.Exception.Message
}
finally {
    Write-Host "End"
} #>

$filePath = '.\bogusFile.txt'
try {
    Get-Content $filePath
} catch {
    Write-Host "We found an error"
}
$folderPath = '.\bogusFolder'
try {
    $files = Get-ChildItem -Path $folderPath –ErrorAction Stop
    $files.foreach({
        $fileText = Get-Content $files
        $fileText[0]
    })
} catch {
    $_.Exception.Message
}