using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PatientRegistryConsole
{
    internal class UpdateHistory
    {
        public string OldValue { get; set; }
        public string NewValue { get; set; }
        public DateTime Timestamp { get; set; }
        public UpdateHistory()
        {
            Timestamp = DateTime.Now;
        }
        public string ToString()
        {
            return $"[{Timestamp:yyyy-MM-dd HH:mm:ss}] {OldValue} -> {NewValue}";
        }
    }
}