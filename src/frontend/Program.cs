using kdg_demo.Models;
using kdg_demo.Services;
using Microsoft.AspNetCore.Components.Server.Circuits;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor().AddHubOptions(options => options.KeepAliveInterval = TimeSpan.FromSeconds(5));
builder.Services.AddSingleton<CircuitHandler, TrackingCircuitHandler>();


var app = builder.Build();

app.UseStaticFiles();
app.UseRouting();
app.MapBlazorHub();
app.MapFallbackToPage("/_Host");

app.MapGet("/sessions", ([FromServices] IServiceProvider services) =>
{
	var handlers = services.GetServices<CircuitHandler>();
	var handler = handlers.First(h => h.GetType() == typeof(TrackingCircuitHandler)) as TrackingCircuitHandler;
	return Results.Json(new Sessions(handler.ConnectedCircuits));
});

app.Run();
