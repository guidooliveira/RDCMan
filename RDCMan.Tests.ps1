$here = Split-Path -Parent -Path $MyInvocation.MyCommand.Path

$module = 'RDCMan'

Get-Module -Name $module | Remove-Module -Force
Import-Module -Name "$here\$module.psm1"

Describe -Tags ('Unit', 'Acceptance') -Name "$module Module Tests"  -Fixture {
  Context -Name 'Module Setup' -Fixture {
    It -name "has the root module $module.psm1" -test {
      "$here\$module.psm1" | Should Exist
    }

    It -name "has the a manifest file of $module.psm1" -test {
      "$here\$module.psd1" | Should Exist
      "$here\$module.psd1" | Should Contain "$module.psm1"
    }
    
    It -name '$module has functions' -test {
      $moduleFunctions = Get-Command -Module $module
      
      $moduleFunctions.Count | Should Not Be 0
    }

    It -name "$module is valid PowerShell code" -test {
      $psFile = Get-Content -Path "$here\$module.psm1" -ErrorAction Stop
      $errors = $null
      $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
      $errors.Count | Should Be 0
    }
  } #Context 'Module Setup'
}#Describe 'Module Tests'