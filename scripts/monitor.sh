DISK_THRESHOLD=10
CPU_THRESHOLD=30
RAM_THRESHOLD=70
WEBHOOK_URL="https://discord.com/api/webhooks/1420118676014895325/97xm0IXLoWl8Mv0uVaVUcuDKhcFSxAKYoKg9AEDrGWNxPDED2fhytfHXPX7i2npyjK5b"

DISK_USAGE=$(df --output=pcent,target / | tail -n1 | tr -dc '0-9')
if (( DISK_USAGE > DISK_THRESHOLD )); then
    MESSAGE="[$(date '+%Y-%m-%d %H:%M:%S')] Disk Alert. Root '/' usage: ${DISK_USAGE}% (threshold: ${DISK_THRESHOLD}%)"
    # curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$MESSAGE\"}" "$WEBHOOK_URL"
    curl --ssl-no-revoke -H "Content-Type: application/json" -X POST -d "{\"content\": \"$MESSAGE\"}" "$WEBHOOK_URL"
fi

CPU_USAGE=$(wmic cpu get loadpercentage | awk 'NR==2 {print $1}')
if (( CPU_USAGE > CPU_THRESHOLD )); then
    MESSAGE="[$(date '+%Y-%m-%d %H:%M:%S')] CPU Alert. Usage: ${CPU_USAGE}% (threshold: ${CPU_THRESHOLD}%)"
    # curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$MESSAGE\"}" "$WEBHOOK_URL"
    curl --ssl-no-revoke -H "Content-Type: application/json" -X POST -d "{\"content\": \"$MESSAGE\"}" "$WEBHOOK_URL"
fi

RAM_TOTAL=$(wmic computersystem get TotalPhysicalMemory | awk 'NR==2 {print int($1/1024/1024)}')
RAM_FREE=$(wmic OS get FreePhysicalMemory | awk 'NR==2 {print int($1/1024)}')
RAM_USED=$(( RAM_TOTAL - RAM_FREE ))
RAM_USAGE=$(( RAM_USED * 100 / RAM_TOTAL ))

if (( RAM_USAGE > RAM_THRESHOLD )); then
    MESSAGE="[$(date '+%Y-%m-%d %H:%M:%S')] RAM Alert. Usage: ${RAM_USAGE}% (threshold: ${RAM_THRESHOLD}%)"
    # curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$MESSAGE\"}" "$WEBHOOK_URL"
    curl --ssl-no-revoke -H "Content-Type: application/json" -X POST -d "{\"content\": \"$MESSAGE\"}" "$WEBHOOK_URL"
fi