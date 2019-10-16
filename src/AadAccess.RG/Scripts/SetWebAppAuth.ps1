params(
    [string]$appName,
    [string]$resourceGroup
)

$url = 'https://'+$appName+'.azurewebsites.net'

$newApp = Get-AzADApplication -DisplayName "$appName"

if(!$newApp)
{
    $newApp = New-AzADApplication -DisplayName $appName -IdentifierUris $url -HomePage $url
}

$appId = $newApp.AppId

Write-Host 'AppID: '
$appId

$servicePrincipal = Get-AzADServicePrincipal -DisplayName "$appName" | Where-Object {$_.ServicePrincipalType -ne "ManagedIdentity"}

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

$authResourceName = $appName + "/authsettings"

$auth = Invoke-AzResourceAction -ResourceGroupName $resourceGroup -ResourceType Microsoft.Web/sites/config -ResourceName $authResourceName -Action list -ApiVersion 2016-08-01 -Force

$PropertiesObject = @{
    "enabled" = "True";
    "unauthenticatedClientAction" = "RedirectToLoginPage";
    "defaultProvider" = "AzureActiveDirectory";
    "tokenStoreEnabled" = "True";
    "clientId" = "$appId";
    "issuer" = "$issuerUrl";
    "allowedAudiences" = "{ $url+'/.auth/login/aad/callback', $url }";
    "isAadAutoProvisioned" = "False";
}

$props = $auth.properties | ConvertTo-Json

New-AzResource -Properties $PropertiesObject -ResourceGroupName $resourceGroup -ResourceType Microsoft.Web/sites/config -ResourceName $authResourceName -ApiVersion 2016-08-01 -Force

Write-Host 'Auth set on app.'