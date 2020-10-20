
# Querying certain object and changing surname
Get-ADUser -Filter "givenName -eq 'Jane' -and surName –eq 'Jones'" | Set-ADUser -Surname 'Smith'
    # Verify    
    Get-ADUser -Filter "givenName -eq 'Jane' -and surName –eq 'Smith'"

# Changing multiple properties
Get-ADUser -Filter "givenName -eq 'Jane' -and surname –eq 'Smith'" | Set-ADUser -Department 'HR' -Title Director
    # Verify    
    Get-ADUser -Filter "givenName -eq 'Jane' -and surname –eq 'Smith'" -Properties GivenName,SurName,Department,Title
    # NOTE the use of -properties instead of Select-object -property
