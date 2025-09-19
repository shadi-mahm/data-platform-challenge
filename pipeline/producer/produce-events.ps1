
Write-Host "Starting to produce 100 records into Kafka topic 'events'..."

$records = @()
$eventTypes = @("login", "logout", "purchase", "view", "click")
$devices = @("mobile", "desktop", "tablet")

for ($i = 1; $i -le 100; $i++) {
    $eventType = Get-Random -InputObject $eventTypes
    $device = Get-Random -InputObject $devices
    $sessionId = "sess_$(Get-Random -Minimum 1 -Maximum 1000)"
    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    
    $record = @{
        user_id    = "user_$i"
        event_type = $eventType
        timestamp  = $timestamp
        session_id = $sessionId
        device     = $device
    } | ConvertTo-Json -Compress
    
    $records += $record
}

$recordsData = $records -join "`n"

$bashCommand = "echo '$recordsData' | bin/kafka-console-producer.sh --bootstrap-server kafka-cluster-kafka-bootstrap:9092 --topic events --producer-property acks=all --producer-property enable.idempotence=true"

try {
    kubectl run -n kafka kafka-producer -ti --rm --restart=Never `
        --image=quay.io/strimzi/kafka:0.47.0-kafka-4.0.0 `
        -- bash -c $bashCommand

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Successfully produced 100 records."
    }
    else {
        Write-Host "Error: Command failed with exit code $LASTEXITCODE"
        exit $LASTEXITCODE
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}