namespace AadAccess.MVC.Controllers
{
    using System.Diagnostics;
    using Microsoft.AspNetCore.Mvc;
    using Models;
    using Services;
    
    public class HomeController : Controller
    {
        private readonly FunctionsValueService _functionsValueService;
        private readonly ApiValueService _apiValueService;
        private readonly KeyVaultService _keyVaultService;

        public HomeController()
        {
            _functionsValueService = new FunctionsValueService();
            _apiValueService = new ApiValueService();
            _keyVaultService = new KeyVaultService();
        }
        
        public IActionResult Index()
        {
            ViewData["FunctionsValue"] = _functionsValueService.GetValue("ValueFunction");
            ViewData["ApiValue"] = _apiValueService.GetValue("Value");
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