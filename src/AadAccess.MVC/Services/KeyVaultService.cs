namespace AadAccess.MVC.Services
{
    using System.Configuration;
    using Microsoft.Azure.KeyVault;
    using Microsoft.Azure.Services.AppAuthentication;

    public class KeyVaultService
    {
        private readonly string _keyVaultUrl;
        private readonly KeyVaultClient _keyVaultClient;

        public KeyVaultService()
        {
            _keyVaultUrl = ConfigurationManager.AppSettings["KeyVaultUrl"];

            AzureServiceTokenProvider azureServiceTokenProvider = new AzureServiceTokenProvider();
            _keyVaultClient =
                new KeyVaultClient(
                    new KeyVaultClient.AuthenticationCallback(azureServiceTokenProvider.KeyVaultTokenCallback));
        }

        public string GetSecretValue => GetSecret("Secret");

        private string GetSecret(string secretName)
        {
            var sec = _keyVaultClient.GetSecretAsync(_keyVaultUrl, secretName);
            return sec.Result.Value;
        }
    }
}