
<#
~ Test pester code. NOTE: this was performed on a domain-joined computer 
@ To execute this - run Invoke-Pester followed by the path to & name of the script
@ Each block (describe, context, it) requires a name! 
#>

describe 'RDS'{
    Context 'File-Services' {
        # NOTE the It command states it will install file-services but we are verifying if it exists first with Get-WindowsFeature
        it 'Installs files Services'{
            # Actually saying assertion isn't necessary. Whatever is inside the "it block" is the assertion
            # remember to put =@ when splatting
            $parameters = @{
                computername = 'RDS01'
                name = 'File-Services'
            }
            # we don't need the name of the feature returned ONLY if it has been installed. So we surround in round brackets and specifiy .installed
            # 'Should be' is the Pester testing syntax
            (Get-WindowsFeature @parameters).Installed | Should be $true
        }
    }

}

# Then run invoke-pester