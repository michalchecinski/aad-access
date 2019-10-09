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

        public HomeController()
        {
            _functionsValueService = new FunctionsValueService();
            _apiValueService = new ApiValueService();
        }
        
        public IActionResult Index()
        {
            ViewData["FunctionsValue"] = _functionsValueService.GetValue("ValueFunction");
            ViewData["ApiValue"] = _apiValueService.GetValue("Value");
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