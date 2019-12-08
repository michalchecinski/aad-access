namespace AadAccess.MVC.Services
{
    using System;
    using System.Threading.Tasks;
    using Microsoft.Azure.Services.AppAuthentication;

    public class ManagedIdentityRequestToken
    {
        public async Task<string> GetToken(string appId)
        {
            var azureServiceTokenProvider = new AzureServiceTokenProvider();
            return await azureServiceTokenProvider.GetAccessTokenAsync(appId);
        }
    }
}