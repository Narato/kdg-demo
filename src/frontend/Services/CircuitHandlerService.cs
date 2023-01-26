using Microsoft.AspNetCore.Components.Server.Circuits;

namespace kdg_demo.Services
{
	public class CircuitHandlerService : CircuitHandler
	{
		public string CircuitId { get; set; }

		private readonly ISessionService sessions;

		public CircuitHandlerService(ISessionService sessions)
		{
			this.sessions = sessions;
		}

		public override Task OnCircuitOpenedAsync(Circuit circuit, CancellationToken cancellationToken)
		{
			CircuitId = circuit.Id;
			sessions.Connect(CircuitId);
			return base.OnCircuitOpenedAsync(circuit, cancellationToken);
		}

		public override Task OnCircuitClosedAsync(Circuit circuit, CancellationToken cancellationToken)
		{
			sessions.DisConnect(circuit.Id);
			return base.OnCircuitClosedAsync(circuit, cancellationToken);
		}
	}
}