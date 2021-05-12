function New-RDCManFile
{
  <#
      .SYNOPSIS
      Creates a new Remote Desktop Connection Manager File.

      .DESCRIPTION
      Creates a new Remote Desktop Connection Manager File for version 2.7
      which can then be modified.
      .PARAMETER  FilePath
      Input the path for the file you wish to Create.

      .PARAMETER  Name
      Input the name for the Structure within the file.

      .EXAMPLE
      PS C:\> New-RDCManFile -FilePath .\Test.rdg -Name RDCMan
      'If no output is generated the command was run successfully'
      This example shows how to call the Name function with named parameters.


      .INPUTS
      System.String

      .OUTPUTS
      Null
  #>
  Param(
    [Parameter(Mandatory = $true)]
    [String]$FilePath,
    
    [Parameter(Mandatory = $true)]
    [String]$Name
  )
  BEGIN
  {
    [string]$template = @' 
<?xml version="1.0" encoding="utf-8"?>
<RDCMan programVersion="2.7" schemaVersion="3">
  <file>
    <credentialsProfiles />
    <properties>
      <expanded>True</expanded>
      <name></name>
    </properties>
  </file>
  <connected />
  <favorites />
  <recentlyUsed />
</RDCMan>
'@ 
    $FilePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($FilePath)
    if(Test-Path -Path $FilePath)
    {
      Write-Error -Message 'File Already Exists'
    }
    else
    {
      $xml = New-Object -TypeName Xml
      $xml.LoadXml($template)
    }
  }
  PROCESS
  {
    $File = (@($xml.RDCMan.file.properties)[0]).Clone()
    $File.Name = $Name
    
    $xml.RDCMan.file.properties |
    Where-Object -FilterScript {
      $_.Name -eq ''
    } |
    ForEach-Object -Process {
      [void]$xml.RDCMan.file.ReplaceChild($File,$_)
    }
  }
  END
  {
    $xml.Save($FilePath)
  }
}
function New-RDCManGroup
{
  <#
      .SYNOPSIS
      Creates a new Group within your Remote Desktop Connection Manager File.

      .DESCRIPTION
      Creates a new Group within your Remote Desktop Connection Manager File for version 2.7.
      which can then be modified.
      .PARAMETER  FilePath
      Input the path for the file you wish to Create.

      .PARAMETER  Name
      Input the name for the Group you wish to create within the file.

      .EXAMPLE
      PS C:\> New-RDCManGroup -FilePath .\Test.rdg -Name RDCMan
      'If no output is generated the command was run successfully'
      This example shows how to call the Name function with named parameters.


      .INPUTS
      System.String

      .OUTPUTS
      Null
  #>
  Param(
    [Parameter(Mandatory = $true)]
    [String]$FilePath,
    
    [Parameter(Mandatory = $true)]
    [String]$Name
  )
  BEGIN
  {
    $FilePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($FilePath)
    if(Test-Path -Path $FilePath)
    {
      $xml = New-Object -TypeName XML
      $xml.Load($FilePath)
    } 
    else
    {
      Write-Error -Exception $_.Exception
      throw $_.Exception
    }
  }
  PROCESS
  {
    $group = $xml.CreateElement('group')
    $grouproperties = $xml.CreateElement('properties')
      
    $groupname = $xml.CreateElement('name')
    $groupname.set_InnerXML($Name)
      
    $groupexpanded = $xml.CreateElement('expanded')
    $groupexpanded.set_InnerXML('False')
      
    [void]$grouproperties.AppendChild($groupname)
    [void]$grouproperties.AppendChild($groupexpanded)
      
    [void]$group.AppendChild($grouproperties)
    [void]$xml.RDCMan.file.AppendChild($group)
  }
  END
  {
    $xml.Save($FilePath)
  }
}
function New-RDCManServer
{
  <#
      .SYNOPSIS
      Creates a new Server within a group in your Remote Desktop Connection Manager File.

      .DESCRIPTION
      Creates a new server within the  Remote Desktop Connection Manager File.

      .PARAMETER  FilePath
      Input the path for the file you wish to append a new group.

      .PARAMETER  DisplayName
      Input the name DisplayName of the server.
      
      .PARAMETER  Server
      Input the FQDN, IP Address or Hostname of the server.

      .PARAMETER  GroupName
      Input the name DisplayName of the server.

      .EXAMPLE
      PS C:\> New-RDCManServer -FilePath .\Test.rdg -DisplayName RDCMan -Server '10.10.0.5' -Group Test
      'If no output is generated the command was run successfully'
      This example shows how to call the Name function with named parameters.

      .INPUTS
      System.String

      .OUTPUTS
      Null
  #>
  Param(
    [Parameter(Mandatory = $true)]
    [String]$FilePath,
    
    [Parameter(Mandatory = $true)]
    [String]$GroupName,

    [Parameter(Mandatory = $true)]
    [String]$Server,

    [Parameter(Mandatory = $true)]
    [String]$DisplayName,

    [Parameter(Mandatory = $false, HelpMessage="Use DOMAIN\USER format, if it's a local account use . to represent the domain")]
    [pscredential]$Credential
  )
  BEGIN
  {
    $Binarypath = Join-Path -Path (Get-Module -Name RDCMan).ModuleBase -ChildPath 'bin' -AdditionalChildPath 'RDCMan.dll'
    Import-Module $Binarypath
    $FilePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($FilePath)
    if(Test-Path -Path $FilePath)
    {
      $xml = New-Object -TypeName XML
      $xml.Load($FilePath)
    } 
    else
    {
      Write-Error -Exception $_.Exception
      throw $_.Exception
    }
  }
  PROCESS
  {
    $ServerNode = $xml.CreateElement('server')
    $serverproperties = $xml.CreateElement('properties')

    $servername = $xml.CreateElement('name')
    $servername.set_InnerXML($Server)
    
    $serverdisplayname = $xml.CreateElement('displayName')
    $serverdisplayname.set_InnerXML($DisplayName)

    if($Credential){
      $logonCredentials = $xml.CreateElement('logonCredentials')
      $inherit = $xml.CreateAttribute('inherit')
      $inherit.Value = 'None'
      [void]$logonCredentials.Attributes.Append($inherit)
      
      $profileName = $xml.CreateElement('profileName')
      $profileName.set_InnerXML('Custom')
      $scope = $xml.CreateAttribute('scope')
      $scope.Value = 'Local'
      [void]$profileName.Attributes.Append($inherit)
      

      $userName = $xml.CreateElement('userName')
      $usernamestr = $Credential.UserName.split('\')[1]
      $userName.set_InnerXML($usernamestr)

      $domain = $xml.CreateElement('domain')
      $domainstr = $Credential.UserName.split('\')[0]
      $domain.set_InnerXML($domainstr)
      
      $EncryptionSettings = New-Object -TypeName RdcMan.EncryptionSettings
      $EncryptedPassword = [RdcMan.Encryption]::EncryptString($Credential.GetNetworkCredential().Password, $EncryptionSettings)
      $password = $xml.CreateElement('password')
      $password.set_InnerXML($EncryptedPassword)
      
      [void]$logonCredentials.AppendChild($profileName)
      [void]$logonCredentials.AppendChild($userName)
      [void]$logonCredentials.AppendChild($password)
      [void]$logonCredentials.AppendChild($domain)
      
      [void]$ServerNode.AppendChild($logonCredentials)
    }

    [void]$serverproperties.AppendChild($servername)
    [void]$serverproperties.AppendChild($serverdisplayname)

    [void]$ServerNode.AppendChild($serverproperties)

    $group = @($xml.RDCMan.file.group) | Where-Object -FilterScript {
      $_.properties.name -eq $groupname
    } 
    [void]$group.AppendChild($ServerNode)
  }
  END
  {
    $xml.Save($FilePath)
  }
}
function Remove-RDCManServer
{
  <#
      .SYNOPSIS
      Removes a Server from the Remote Desktop Connection Manager File.

      .DESCRIPTION
      Removes a Server from the Remote Desktop Connection Manager File.

      .PARAMETER  FilePath
      Input the path for the file you wish to Create.

      .PARAMETER  Name
      Input the name for the Structure within the file.

      .EXAMPLE
      PS C:\> Remove-RDCManServer -FilePath .\Test.rdg -DisplayName RDCMan
      'If no output is generated the command was run successfully'
      This example shows how to call the Name function with named parameters.


      .INPUTS
      System.String

      .OUTPUTS
      Null
  #>
  Param(
    [Parameter(Mandatory = $true)]
    [String]$FilePath,

    [Parameter(Mandatory = $true)]
    [String]$DisplayName
  )
  BEGIN
  {
    $FilePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($FilePath)
    if(Test-Path -Path $FilePath)
    {
      $xml = New-Object -TypeName XML
      $xml.Load($FilePath)
    } 
    else
    {
      Write-Error -Exception $_.Exception
      throw $_.Exception
    }
  }
  PROCESS
  {
    $xml.RDCMan.file.group.server |
    Where-Object -FilterScript {
      $_.properties.displayname -eq $DisplayName 
    } |
    ForEach-Object  -Process {
      [void]$xml.RDCMan.file.group.RemoveChild($_) 
    } 
  }
  END
  {
    $xml.Save($FilePath)
  }
}
function Remove-RDCManGroup
{
  <#
      .SYNOPSIS
      Removes a Group from the Remote Desktop Connection Manager File.

      .DESCRIPTION
      Creates a new Remote Desktop Connection Manager File for version .
      which can then be modified.

      .PARAMETER  FilePath
      Input the path for the file you wish to Create.

      .PARAMETER  Name
      Input the name for of the group within the file.

      .EXAMPLE
      PS C:\> Remove-RDCManGroup -FilePath .\Test.rdg -Name RDCMan
      'If no output is generated the command was run successfully'
      This example shows how to call the Name function with named parameters.


      .INPUTS
      System.String

      .OUTPUTS
      Null
  #>
  Param(
    [Parameter(Mandatory = $true)]
    [String]$FilePath,

    [Parameter(Mandatory = $true)]
    [String]$Name
  )
  BEGIN
  {
    $FilePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($FilePath)
    if(Test-Path -Path $FilePath)
    {
      $xml = New-Object -TypeName XML
      $xml.Load($FilePath)
    } 
    else
    {
      Write-Error -Exception $_.Exception
      throw $_.Exception
    }
  }
  PROCESS
  {
    $xml.RDCMan.file.group |
    Where-Object -FilterScript {
      $_.properties.name -eq $Name 
    } |
    ForEach-Object  -Process {
      [void]$xml.RDCMan.file.RemoveChild($_) 
    } 
  }
  END
  {
    $xml.Save($FilePath)
  }
}
