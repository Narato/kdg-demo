using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Components.Server.Circuits;

namespace kdg_demo.Services
{
	public class TrackingCircuitHandler : CircuitHandler
	{
		private readonly HashSet<Circuit> circuits = new();

		public override Task OnConnectionUpAsync(Circuit circuit,
			CancellationToken cancellationToken)
		{
			circuits.Add(circuit);

			return Task.CompletedTask;
		}

		public override Task OnConnectionDownAsync(Circuit circuit,
			CancellationToken cancellationToken)
		{
			circuits.Remove(circuit);

			return Task.CompletedTask;
		}

		public int ConnectedCircuits => circuits.Count;
	}
}