param(
    [string]$securedAppName,
	[string]$clientAppName,
	[string]$roleName
)

Write-Host 'Installing AzureAD module'
Install-Module -Name AzureAD -Force -Scope CurrentUser

Write-Host 'Connecting to AzureAD'
$currentAzureContext = Get-AzContext
$tenantId = $currentAzureContext.Tenant.Id
$accountId = $currentAzureContext.Account.Id
Connect-AzureAD -TenantId $tenantId -AccountId $accountId
Write-Host 'Connected to AzureAD'

$app = Get-AzureADApplication -Filter "DisplayName eq '$securedAppName'"

if(!$app)
{
    Write-Error "App with name [$securedAppName] does not exist"
	exit
}

Write-Host 'App:'
$app

$servicePrincipal = Get-AzureADServicePrincipal -Filter "DisplayName eq '$securedAppName'"  | Where-Object {$_.ServicePrincipalType -ne "ManagedIdentity"}

if(!$servicePrincipal)
{
    Write-Error "Service principal with name [$securedAppName] does not exist"
	exit
}

Write-Host 'Service principal:'
$servicePrincipal

Function CreateAppRole([string] $Name, [string] $AppId, [System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.AppRole]]$appRoles)
{
    $appRole = New-Object Microsoft.Open.AzureAD.Model.AppRole
    $appRole.AllowedMemberTypes = New-Object System.Collections.Generic.List[string]
    $appRole.AllowedMemberTypes.Add("Application");
    $appRole.DisplayName = $Name
    $appRole.Id = New-Guid
    $appRole.IsEnabled = $true
    $appRole.Description = "$Name role"
    $appRole.Value = $Name;

	$appRoles.Add($appRole)

	Set-AzureADApplication -ObjectId $AppId -AppRoles $appRoles

	return $appRole.Id
}

$appRoles = $app.AppRoles

if($appRoles)
{
	$role = $app.AppRoles | Where-Object {$_.Value -eq  $roleName}
	if($role)
	{
		$roleId = $role.Id
	}
	else
	{
		$roleId = CreateAppRole -Name $roleName -AppId $app.ObjectId -appRoles $appRoles
	}
}
else
{
	$appRoles = New-Object System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.AppRole]

	$roleId = CreateAppRole -Name $roleName -AppId  $app.ObjectId -appRoles $appRoles
}

Write-Host "New app role id:"
$roleId

$bizSparkUser = (Get-AzADServicePrincipal -DisplayName $clientAppName).Id.ToString()

try
{
    New-AzureADServiceAppRoleAssignment -ObjectId $bizSparkUser -Id $roleId -PrincipalId $bizSparkUser -ResourceId $servicePrincipal.ObjectId
}
catch
{
    Write-Host "Exception: $_"
}