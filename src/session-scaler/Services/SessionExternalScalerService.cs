
using Externalscaler;
using Grpc.Core;
using session_scaler.Models;

namespace session_scaler.Services
{
	public class SessionExternalScalerService : ExternalScaler.ExternalScalerBase
	{

		private readonly IHttpClientFactory httpClientFactory;

		private async Task<Sessions> GetConnectedSessions()
		{
			Console.WriteLine($"Getting sessions");
			var httpClient = httpClientFactory.CreateClient("Sessions");
			return await httpClient.GetFromJsonAsync<Sessions>("/sessions");
		}

		public SessionExternalScalerService(IHttpClientFactory httpClientFactory)
		{
			this.httpClientFactory = httpClientFactory;
		}

		public override async Task<IsActiveResponse> IsActive(ScaledObjectRef request, ServerCallContext context)
		{
			var sessions = await GetConnectedSessions();
			return new IsActiveResponse
			{
				// return true if there are active circuits
				Result = sessions.NumberOfActiveSessions > 0
			};
		}

		public override async Task StreamIsActive(ScaledObjectRef request, IServerStreamWriter<IsActiveResponse> responseStream, ServerCallContext context)
		{

			while (!context.CancellationToken.IsCancellationRequested)
			{
				var sessions = await GetConnectedSessions();
				if (sessions.NumberOfActiveSessions > 0)
					await responseStream.WriteAsync(new IsActiveResponse { Result = true });

				await Task.Delay(TimeSpan.FromSeconds(10));
			}
		}

		public override Task<GetMetricSpecResponse> GetMetricSpec(ScaledObjectRef request, ServerCallContext context)
		{
			if (!request.ScalerMetadata.ContainsKey("sessionCount"))
				throw new ArgumentException("Session count must be specified");

			if (!long.TryParse(request.ScalerMetadata["sessionCount"], out var sessionCount))
				throw new ArgumentException("Session count must be an integer");

			var resp = new GetMetricSpecResponse();
			resp.MetricSpecs.Add(new MetricSpec
			{
				MetricName = "sessionThreshold",
				TargetSize = sessionCount
			});

			return Task.FromResult(resp);
		}

		public override async Task<GetMetricsResponse> GetMetrics(GetMetricsRequest request, ServerCallContext context)
		{
			var sessions = await GetConnectedSessions();
			var resp = new GetMetricsResponse();
			resp.MetricValues.Add(new MetricValue
			{
				MetricName = "sessionThreshold",
				MetricValue_ = sessions.NumberOfActiveSessions
			});

			return resp;
		}
	}
}
