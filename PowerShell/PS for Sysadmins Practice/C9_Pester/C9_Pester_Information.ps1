<# 
~ Testing with Pester
#>

# Describe block - groups similar tests together
Describe "DescribeName" {
    
}

# Optional Context Block - groups similar 'It' blocks together
Describe "DescribeName" {
    Context "ContextName"{

    }
}

# It Block - labels the actual test
Describe "DescribeName" {
    Context "ContextName"{
        It "ItName"{

        }
    }
}

# Assertions - actual code that performs the test
Describe "DescribeName" {
    Context "ContextName" {
        It "ItName" {
            Assertion
        }
    }
}
