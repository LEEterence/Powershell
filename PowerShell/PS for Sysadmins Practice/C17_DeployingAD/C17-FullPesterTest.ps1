<# 
~ Post-AD DS setup and domain population testing
! Changes to new version of Pester requires 2 THINGS
!   1. All operators after 'Should' require a dash IE. Should -be
!   2. All variables created have to be placed within a BeforeAll or BeforeEach block
#>

Describe 'AD Forest'{
    context 'Domain' {
        BeforeAll {
            $domain =  Get-AdDomain 
            $forest =  Get-AdForest 
            # If running remotely
            #$domain = Invoke-Command -Session $session -ScriptBlock { Get-AdDomain }
            #$forest = Invoke-Command -Session $session -ScriptBlock { Get-AdForest }
        }
        it "the domain mode should be Windows2016Domain" {
            $domain.DomainMode | should -be 'Windows2016Domain'
        }
        it "the forest mode should be WinThreshold" {
            $forest.ForestMode | should -be 'Windows2016Forest'
        }
        it "the domain name should be powerlab.local" {
            $domain.Name | should -be 'powerlab'
        }
    }
}
Describe 'AD Objects'{
    BeforeEach{
    }
    context 'OUs'{
        It 'There should be an OU called department computers'{

        }
        It 'There should be an OU called department users'{

        }
        It 'There should be an OU called department workstations'{
            
        }
        It 'There should be an OU called department servers'{
            
        }
        It 'There should be an OU called IT'{
            
        }
    }
}