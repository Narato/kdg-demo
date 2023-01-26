using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace kdg_demo.Services
{
	public interface ISessionService
	{
		void Connect(string circuitId);
		void DisConnect(string circuitId);
		int GetSessionCount();
	}
}