# Installing Hyper-V
Install-WindowsFeature -Name Hyper-V -ComputerName "computer_name" -IncludeManagementTools -Restart

# NOTE: remember to enable extended Hyper-v settings to enable copy-pasta and resolution adjustment

#change vm resolution after prompt #@ in CMD-line
#VMConnect.exe "<ServerName>" "<VMName>" /edit