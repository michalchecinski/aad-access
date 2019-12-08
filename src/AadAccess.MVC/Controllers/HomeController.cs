namespace AadAccess.MVC.Controllers
{
    using System.Diagnostics;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Extensions.Configuration;
    using Models;
    using Services;
    
    public class HomeController : Controller
    {
        private readonly FunctionsValueService _functionsValueService;
        private readonly ApiValueService _apiValueService;
        private readonly KeyVaultService _keyVaultService;

        public HomeController(IConfiguration config)
        {
            _functionsValueService = new FunctionsValueService(config);
            _apiValueService = new ApiValueService(config);
            _keyVaultService = new KeyVaultService(config);
        }
        
        public async System.Threading.Tasks.Task<IActionResult> IndexAsync()
        {
            ViewData["FunctionsValue"] = await _functionsValueService.GetValue("ValueFunction");
            ViewData["ApiValue"] = await _apiValueService.GetValue("Value");
            ViewData["KeyVaultValue"] = _keyVaultService.GetSecretValue;

            return View();
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel {RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier});
        }
    }
}