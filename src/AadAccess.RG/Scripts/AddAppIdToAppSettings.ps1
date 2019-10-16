param(
	[string]$webAppName,
	[string]$webAppResourceGroupName,
    [string]$aadAppName
)

$appId = (Get-AzADServicePrincipal -DisplayName $aadAppName).ApplicationId.ToString()

$webApp = Get-AzWebApp -ResourceGroupName $webAppResourceGroupName -Name $webAppName

$appSettings = $webApp.SiteConfig.AppSettings

$table = new-object System.Collections.Hashtable
for ( $i = 0; $i -lt $appSettings.Count; $i += 1 ) {
  $table.Add($appSettings[$i].Name, $appSettings[$i].Value);
}
$table.Add("Authentication:AppId", $appId)

Set-AzWebApp -ResourceGroupName $webAppResourceGroupName -Name  $webAppName -AppSettings $table