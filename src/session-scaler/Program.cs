using session_scaler.Services;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddGrpc();
builder.Services.AddGrpcReflection();

builder.Services.AddHttpClient("Sessions", HttpClient =>
	HttpClient.BaseAddress = new Uri(
		Environment.GetEnvironmentVariable("SESSION_ENDPOINT")
		?? throw new ArgumentNullException("Session_Endpoint", "No SESSION_ENDPOINT Provided")
	));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
	app.UseSwagger();
	app.UseSwaggerUI();
}

app.UseRouting();

app.MapGrpcService<SessionExternalScalerService>();
app.MapGrpcReflectionService();

app.Run();
