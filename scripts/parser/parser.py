import argparse
import re
from collections import Counter


parser = argparse.ArgumentParser(description="Web server log analyzer")
parser.add_argument("logfile", help="Path to the Apache/Nginx log file")
parser.add_argument("-o", "--output", default="report.html", help="Output HTML report")
args = parser.parse_args()

ip_counter = Counter()
ua_counter = Counter()
status_counter = Counter()

log_pattern = re.compile(
    r'(?P<ip>\d+\.\d+\.\d+\.\d+) - - \[.*?\] ".*?" (?P<status>\d+) .* ".*?" "(?P<ua>.*?)"'
)

with open(args.logfile, "r") as f:
    for line in f:
        match = log_pattern.match(line)
        if match:
            ip_counter[match.group("ip")] += 1
            status_counter[match.group("status")] += 1
            ua_counter[match.group("ua")] += 1


html = f"""
<html>
<head><title>Web Server Log Report</title></head>
<body>
<h1>Web Server Log Report</h1>

<h2>Top IP Addresses</h2>
<ul>
{''.join(f"<li>{ip}: {count}</li>" for ip, count in ip_counter.most_common(10))}
</ul>

<h2>Top User Agents</h2>
<ul>
{''.join(f"<li>{ua}: {count}</li>" for ua, count in ua_counter.most_common(10))}
</ul>

<h2>HTTP Status Codes</h2>
<ul>
{''.join(f"<li>{status}: {count}</li>" for status, count in status_counter.items())}
</ul>

</body>
</html>
"""

with open(args.output, "w") as f:
    f.write(html)

print(f"Report saved to {args.output}")
