import requests
import time
import json
import csv
import argparse
from datetime import datetime
from pathlib import Path

DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1420118676014895325/97xm0IXLoWl8Mv0uVaVUcuDKhcFSxAKYoKg9AEDrGWNxPDED2fhytfHXPX7i2npyjK5b"
SLOW_THRESHOLD = 1.0  # warn if response is slower than [seconds]

def send_discord_alert(message: str):
    payload = {"content": message}
    try:
        requests.post(DISCORD_WEBHOOK, json=payload, timeout=5)
    except Exception as e:
        print(f"[WARN] Failed to send Discord alert: {e}")

def check_endpoint(url: str):
    try:
        start = time.time()
        response = requests.get(url, timeout=5)
        elapsed = round(time.time() - start, 3)
        return {
            "endpoint": url,
            "status_code": response.status_code,
            "response_time": elapsed,
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "error": None
        }
    except requests.exceptions.RequestException as e:
        return {
            "endpoint": url,
            "status_code": "ERROR",
            "response_time": None,
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "error": str(e)
        }

def save_to_json(data, filename):
    with open(filename, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=4, ensure_ascii=False)

def save_to_csv(data, filename):
    fieldnames = ["timestamp", "endpoint", "status_code", "response_time", "error"]
    with open(filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for entry in data:
            writer.writerow(entry)


def main():
    parser = argparse.ArgumentParser(description="API Monitoring Script")
    parser.add_argument("--endpoints", type=str, help="Comma-separated list of API endpoints")
    parser.add_argument("--file", type=str, help="File containing endpoints (one per line)")
    parser.add_argument("--format", type=str, choices=["json", "csv"], default="json",
                        help="Output format (json or csv)")
    parser.add_argument("--output", type=str, help="Output filename (optional)")

    args = parser.parse_args()

    endpoints = []
    if args.endpoints:
        endpoints.extend([e.strip() for e in args.endpoints.split(",") if e.strip()])
    if args.file:
        file_path = Path(args.file)
        if file_path.exists():
            endpoints.extend([line.strip() for line in file_path.read_text(encoding="utf-8").splitlines() if line.strip()])
        else:
            print(f"[ERROR] Endpoint file not found: {args.file}")
            return

    if not endpoints:
        print("[ERROR] No endpoints provided. Use --endpoints or --file")
        return

    results = [check_endpoint(url) for url in endpoints]

    for result in results:
        status = result["status_code"]
        rt = result["response_time"] or 0
        if status != "ERROR" and isinstance(status, int) and status >= 200 and status < 300:
            if rt > SLOW_THRESHOLD:
                msg = f"API ALERT: {result['endpoint']} is slow. Response time: {rt}s"
                send_discord_alert(msg)
        else:
            msg = f"API ALERT: {result['endpoint']} failed. Status: {status}, Response time: {rt}, Error: {result.get('error')}"
            send_discord_alert(msg)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = args.output or f"results_{timestamp}.{args.format}"

    if args.format == "json":
        save_to_json(results, filename)
    else:
        save_to_csv(results, filename)

    print(f"[INFO] Results saved to {filename}")

if __name__ == "__main__":
    main()
