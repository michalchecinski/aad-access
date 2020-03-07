namespace AadAccess.MVC.Services
{
    using System.Net.Http;
    using System.Net.Http.Headers;
    using System.Threading.Tasks;
    using Flurl;
    using Microsoft.Extensions.Configuration;

    public class FunctionsValueService
    {
        private readonly ManagedIdentityRequestToken _managedIdentityRequestToken;
        private readonly HttpClient _httpClient;
        private readonly string _appId;
        private readonly string _apiBaseAddress;

        public FunctionsValueService(IConfiguration config)
        {
            _managedIdentityRequestToken = new ManagedIdentityRequestToken();
            _httpClient = new HttpClient();
            
            _appId = config["FunctionsAppId"];
            
            var baseAddress = config["FunctionsBaseAddress"];
            _apiBaseAddress = Url.Combine(baseAddress, "api");
        }

        public async Task<string> GetValue(string requestUri)
        {
            var token = await _managedIdentityRequestToken.GetToken(_appId);
            _httpClient.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Bearer", token);
            string value;
            try
            {
                var url = $"{_apiBaseAddress}/{ requestUri}";
                value = await _httpClient.GetStringAsync(url);
            }
            catch (System.Exception e)
            {
                var m = e.Message;
                throw;
            }

            return value;
        }
    }
}