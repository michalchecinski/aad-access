namespace AadAccess.MVC.Services
{
    using Microsoft.Azure.KeyVault;
    using Microsoft.Azure.Services.AppAuthentication;
    using Microsoft.Extensions.Configuration;

    public class KeyVaultService
    {
        private readonly string _keyVaultUrl;
        private readonly KeyVaultClient _keyVaultClient;

        public KeyVaultService(IConfiguration config)
        {
            _keyVaultUrl = config["KeyVaultUrl"];

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