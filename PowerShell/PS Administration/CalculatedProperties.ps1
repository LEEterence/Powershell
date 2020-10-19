<# 
~ Purpose of Calculated Properties: display parameters that AREN'T DEFAULT
~ Format of calculated expression is always within a Hashtable. 
    @ Format is always Name then Exrpression. Where Name is the name of the Existing or New Parameter and Expression is the calculation performed resulting inthe value in the output.
    @ Reminder: No quotations are required for Name or Expression, but you can put it in if you want to
#>
Get-ChildItem | Select-Object -property @{Name='Bracketed Name';Expression={"[$($_.Name)]"} },Directory,@{Name="Custom ComputerName";Expression = {hostname}}