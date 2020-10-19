# Creating an Excel workbook
Get-Process | Export-Excel C:\Processes.xlsx 
# Adding sheets to Excel Workbook
Get-Process | Export-Excel C:\Processes.xlsx -WorksheetName 'Second Sheet'
Get-Process | Export-Excel C:\Processes.xlsx -WorksheetName 'Third Sheet'
# Parsing through Workbook
Import-Excel C:\Processes.xlsx
# Grab information on all sheets within Workbook
Get-ExcelSheetInfo C:\Processes.xlsx
# Parsing data from all sheets
$excelSheets = Get-ExcelSheetInfo -Path .\delete.xlsx
Foreach ($sheet in $excelSheets){
    $workSheetName = $sheet.Name
    $sheetRows = Import-Excel -Path .\delete.xlsx -WorkSheetName $workSheetName 
    # Use a calculated property here because there is no parameter named Worksheet for Import-Excel
    # Calcualted properties are always used in hashtables
    $sheetRows | Select-Object -Property *,@{'Name'='Worksheet';'Expression'={ $workSheetName }}
}

