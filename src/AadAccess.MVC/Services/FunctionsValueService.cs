namespace AadAccess.MVC.Services
{
    using System.Configuration;
    using System.Net.Http;
    using System.Net.Http.Headers;
    using System.Threading.Tasks;
    using Flurl;
    
    public class FunctionsValueService
    {
        private readonly ManagedIdentityRequestToken _managedIdentityRequestToken;
        private readonly HttpClient _httpClient;
        private readonly string _appId;
        private readonly string _apiBaseAddress;

        public FunctionsValueService()
        {
            _managedIdentityRequestToken = new ManagedIdentityRequestToken();
            _httpClient = new HttpClient();
            
            _appId = ConfigurationManager.AppSettings["FunctionsAppId"];
            
            var baseAddress = ConfigurationManager.AppSettings["FunctionsBaseAddress"];
            _apiBaseAddress = Url.Combine(baseAddress, "api");
        }

        public async Task<string> GetValue(string requestUri)
        {
            var token = await _managedIdentityRequestToken.GetToken(_appId);
            _httpClient.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Bearer", token);

            return await _httpClient.GetStringAsync(_apiBaseAddress.AppendPathSegment(requestUri));
        }
    }
}