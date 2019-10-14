param(
	[string]$functionAppName,
	[string]$resourceGroup
)

$url = 'https://'+$functionAppName+'.azurewebsites.net'

Try
{
     $newApp = New-AzADApplication -DisplayName $functionAppName -IdentifierUris $url -HomePage $url
}
Catch [System.Exception]
{
     $newApp = Get-AzureADApplication -DisplayName "$functionAppName"
}

$appId = $newApp.AppId

Write-Host 'AppID: '
$appId

$servicePrincipal = Get-AzADServicePrincipal -DisplayName "$functionAppName" | Where-Object {$_.ServicePrincipalType -ne "ManagedIdentity"}

if(!$servicePrincipal)
{
	$servicePrincipal = New-AzADServicePrincipal -ApplicationId $newApp.AppId -Homepage $url -Tags {WindowsAzureActiveDirectoryIntegratedApp AppServiceIntegratedApp}
}

$servicePrincipalId = $servicePrincipal.ObjectId

Write-Host 'Service Principal ID: '
$servicePrincipalId

$tenantId = (Get-AzTenant).Id

Write-Host 'Tenant ID: '
$tenantId

$issuerUrl = 'https://sts.windows.net/'+$tenantId

$authResourceName = $functionAppName + "/authsettings"

$auth = Invoke-AzResourceAction -ResourceGroupName $resourceGroup -ResourceType Microsoft.Web/sites/config -ResourceName $authResourceName -Action list -ApiVersion 2016-08-01 -Force

$auth.properties

$auth.properties.enabled = "True"
$auth.properties.unauthenticatedClientAction = "RedirectToLoginPage"
$auth.properties.tokenStoreEnabled = "True"
$auth.properties.defaultProvider = "AzureActiveDirectory"
$auth.properties.isAadAutoProvisioned = "False"
$auth.properties.clientId = $appId
$auth.properties.issuer = $issuerUrl
$auth.properties.allowedAudiences = { $url+'/.auth/login/aad/callback', $url }

New-AzureRmResource -Properties $auth.properties -ResourceGroupName $resourceGroup -ResourceType Microsoft.Web/sites/config -ResourceName $authResourceName -ApiVersion 2016-08-01 -Force

Write-Host 'Auth set on app.'