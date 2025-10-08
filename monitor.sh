DISK_THRESHOLD=1
CPU_THRESHOLD=1
RAM_THRESHOLD=1
WEBHOOK_URL="https://discord.com/api/webhooks/1420118676014895325/97xm0IXLoWl8Mv0uVaVUcuDKhcFSxAKYoKg9AEDrGWNxPDED2fhytfHXPX7i2npyjK5b"

DISK_USAGE=$(df --output=pcent,target / | tail -n1 | tr -dc '0-9')
if (( DISK_USAGE > DISK_THRESHOLD )); then
    MESSAGE="[$(date '+%Y-%m-%d %H:%M:%S')] Disk Alert. Root '/' usage: ${DISK_USAGE}% (threshold: ${DISK_THRESHOLD}%)"
    curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$MESSAGE\"}" "$WEBHOOK_URL"
fi

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2 + $4)}')
if (( CPU_USAGE > CPU_THRESHOLD )); then
    MESSAGE="[$(date '+%Y-%m-%d %H:%M:%S')] CPU Alert. Usage: ${CPU_USAGE}% (threshold: ${CPU_THRESHOLD}%)"
    curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$MESSAGE\"}" "$WEBHOOK_URL"
fi

RAM_USAGE=$(free | awk '/Mem:/ {printf("%d", $3/$2 * 100)}')
if (( RAM_USAGE > RAM_THRESHOLD )); then
    MESSAGE="[$(date '+%Y-%m-%d %H:%M:%S')] RAM Alert. Usage: ${RAM_USAGE}% (threshold: ${RAM_THRESHOLD}%)"
    curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$MESSAGE\"}" "$WEBHOOK_URL"
fi
