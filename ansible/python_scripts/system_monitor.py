#!/usr/bin/env python3
"""
System Monitor Script
Monitors system resources and logs to structured format
"""

import psutil
import json
import datetime
import logging
from pathlib import Path

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)

def get_system_info():
    """Collect system information"""
    try:
        # CPU information
        cpu_percent = psutil.cpu_percent(interval=1)
        cpu_count = psutil.cpu_count()
        cpu_freq = psutil.cpu_freq()
        
        # Memory information
        memory = psutil.virtual_memory()
        swap = psutil.swap_memory()
        
        # Disk information
        disk_usage = psutil.disk_usage('/')
        
        # Network information
        net_io = psutil.net_io_counters()
        
        # System uptime
        boot_time = psutil.boot_time()
        uptime = datetime.datetime.now() - datetime.datetime.fromtimestamp(boot_time)
        
        system_info = {
            'timestamp': datetime.datetime.now().isoformat(),
            'cpu': {
                'percent': cpu_percent,
                'count': cpu_count,
                'frequency': cpu_freq.current if cpu_freq else None
            },
            'memory': {
                'total': memory.total,
                'available': memory.available,
                'percent': memory.percent,
                'used': memory.used,
                'free': memory.free
            },
            'swap': {
                'total': swap.total,
                'used': swap.used,
                'free': swap.free,
                'percent': swap.percent
            },
            'disk': {
                'total': disk_usage.total,
                'used': disk_usage.used,
                'free': disk_usage.free,
                'percent': (disk_usage.used / disk_usage.total) * 100
            },
            'network': {
                'bytes_sent': net_io.bytes_sent,
                'bytes_recv': net_io.bytes_recv,
                'packets_sent': net_io.packets_sent,
                'packets_recv': net_io.packets_recv
            },
            'uptime_seconds': uptime.total_seconds()
        }
        
        return system_info
        
    except Exception as e:
        logger.error(f"Error collecting system info: {e}")
        return None

def main():
    """Main function to collect and log system information"""
    system_info = get_system_info()
    
    if system_info:
        # Log as JSON for easy parsing by ELK stack
        print(json.dumps(system_info))
        logger.info("System information collected successfully")
    else:
        logger.error("Failed to collect system information")

if __name__ == "__main__":
    main()
