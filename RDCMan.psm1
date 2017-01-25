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
		Creates a new Remote Desktop Connection Manager File.

	.DESCRIPTION
		Creates a new Remote Desktop Connection Manager File for version .
 which can then be modified.
	.PARAMETER  FilePath
		Input the path for the file you wish to append a new group.

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
    [String]$GroupName,

    [Parameter(Mandatory = $true)]
    [String]$Server,

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
    $ServerNode = $xml.CreateElement('server')
    $serverproperties = $xml.CreateElement('properties')

    $servername = $xml.CreateElement('name')
    $servername.set_InnerXML($Server)
    
    $serverdisplayname = $xml.CreateElement('displayName')
    $serverdisplayname.set_InnerXML($DisplayName)
    
    [void]$serverproperties.AppendChild($servername)
    [void]$serverproperties.AppendChild($serverdisplayname)

    [void]$ServerNode.AppendChild($serverproperties)

    $group = @($xml.RDCMan.file.group) | Where-Object -FilterScript {
      $_.properties.name -eq $GroupName
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
		Creates a new Remote Desktop Connection Manager File.

	.DESCRIPTION
		Creates a new Remote Desktop Connection Manager File for version .
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
    $xml.RDCMan.file.group.server | Where-Object { $_.properties.displayname -eq $DisplayName } | ForEach-Object  { [void]$xml.RDCMan.file.group.RemoveChild($_) } 
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
		Creates a new Remote Desktop Connection Manager File.

	.DESCRIPTION
		Creates a new Remote Desktop Connection Manager File for version .
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
    $xml.RDCMan.file.group | Where-Object { $_.properties.name -eq $Name } | ForEach-Object  { [void]$xml.RDCMan.file.RemoveChild($_) } 
  }
  END
  {
    $xml.Save($FilePath)
  }
}