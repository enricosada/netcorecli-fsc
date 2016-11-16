namespace MvcApp.Controllers

open System
open System.Collections.Generic
open System.Linq
open System.Threading.Tasks
open Microsoft.AspNetCore.Mvc

type HomeController () =
    inherit Controller()

    member this.Index () =
        this.View()

    member this.About () =
        ViewData.["Message"] <- "Your application description page."
        this.View()

    member this.Contact () =
        ViewData.["Message"] <- "Your contact page."
        this.View()

    member this.IActionResult Error () =
        this.View();
