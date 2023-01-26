using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace kdg_demo.Services
{
	public class SessionService : ISessionService
	{
		private readonly HashSet<string> sessions = new();

		public void Connect(string circuitId) => sessions.Add(circuitId);

		public void DisConnect(string circuitId) => sessions.Remove(circuitId);

		public int GetSessionCount() => sessions.Count;
	}
}