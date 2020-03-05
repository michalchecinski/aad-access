param(
    [string]$appName,
    [string]$resourceGroup
)

$aadAppName = $appName+"-access"

$url = 'https://'+$appName+'.azurewebsites.net'

$newApp = Get-AzADApplication -DisplayName "$aadAppName"

if(!$newApp)
{
    $newApp = New-AzADApplication -DisplayName $aadAppName -IdentifierUris $url -HomePage $url
}

$appId = $newApp.ApplicationId.ToString()

Write-Host 'AppID: '
$appId

$servicePrincipal = Get-AzADServicePrincipal -ApplicationId $appId

if(!$servicePrincipal)
{
	$servicePrincipal = New-AzADServicePrincipal -ApplicationId $appId
}

$servicePrincipalId = $servicePrincipal.Id.ToString()

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