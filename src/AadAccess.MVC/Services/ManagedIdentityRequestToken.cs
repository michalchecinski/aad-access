namespace AadAccess.MVC.Services
{
    using System;
    using System.Threading.Tasks;
    using Microsoft.Azure.Services.AppAuthentication;

    public class ManagedIdentityRequestToken
    {
        private AppAuthenticationResult _authResult;

        public async Task<string> GetToken(string appId)
        {
            if (_authResult != null && _authResult.ExpiresOn >= DateTimeOffset.UtcNow + TimeSpan.FromMinutes(1))
            {
                return _authResult.AccessToken;
            }

            var azureServiceTokenProvider = new AzureServiceTokenProvider();
            _authResult = await azureServiceTokenProvider.GetAuthenticationResultAsync(appId);

            return _authResult.AccessToken;
        }
    }
}