namespace AadAccess.MVC.Services
{
    using System.Net.Http;
    using System.Net.Http.Headers;
    using System.Threading.Tasks;
    using Flurl;
    using Microsoft.Extensions.Configuration;

    public class ApiValueService
    {
        private readonly ManagedIdentityRequestToken _managedIdentityRequestToken;
        private readonly HttpClient _httpClient;
        private readonly string _appId;
        private readonly string _apiBaseAddress;

        public ApiValueService(IConfiguration config)
        {
            _managedIdentityRequestToken = new ManagedIdentityRequestToken();
            _httpClient = new HttpClient();
            
            _appId = config["ApiAppId"];
            
            var baseAddress = config["ApiBaseAddress"];
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