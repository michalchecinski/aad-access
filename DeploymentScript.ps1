function Login
{
    $needLogin = $true
    Try
    {
        $content = Get-AzContext
        if ($content)
        {
            $needLogin = ([string]::IsNullOrEmpty($content.Account))
        }
    }
    Catch
    {
        if ($_ -like "*az login to login*")
        {
            $needLogin = $true
        }
        else
        {
            throw
        }
    }
    if ($needLogin)
    {
        Connect-AzAccount
    }
}


Write-Host 'Loging into Azure...'
Login

New-AzResourceGroup 'aad-access' "West Europe"

New-AzResourceGroupDeployment -ResourceGroupName 'aad-access' `
    -TemplateFile ./src/AadAccess.RG/Templates/azuredeploy.json `
    -TemplateParameterFile  ./src/AadAccess.RG/Templates/azuredeploy.parameters.json

Write-Host "Set webapp auth..."
./src/AadAccess.RG/Scripts/SetWebAppAuth.ps1 -appName aad-access-api -resourceGroup aad-access
./src/AadAccess.RG/Scripts/SetWebAppAuth.ps1 -appName aad-access-functions -resourceGroup aad-access

Write-Host "Add AppId to App Settings..."
./src/AadAccess.RG/Scripts/AddAppIdToAppSettings.ps1 -webAppName aad-access-web `
    -webAppResourceGroupName aad-access `
    -aadAppName aad-access-api-access `
    -appSettingName ApiBaseAddress
./src/AadAccess.RG/Scripts/AddAppIdToAppSettings.ps1 -webAppName aad-access-web `
    -webAppResourceGroupName aad-access `
    -aadAppName aad-access-functions-access `
    -appSettingName FunctionsBaseAddress

Write-Host "Add WebApp to service principals in role..."
./src/AadAccess.RG/Scripts/AddAppToServicePrincipalInRole.ps1 -securedAppName aad-access-api-access -clientAppName aad-access-web -roleName SensitiveData
./src/AadAccess.RG/Scripts/AddAppToServicePrincipalInRole.ps1 -securedAppName aad-access-functions-access -clientAppName aad-access-web -roleName SensitiveData