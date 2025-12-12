# ===============================================
# Auto-Healing & Monitoring Configuration
# Real Estate Intelligence v5.0.0
# ===============================================

## 🏥 **BUILT-IN AUTO-HEALING**

Cloud Run provides automatic healing:
- Restarts failed instances
- Routes traffic away from unhealthy services
- Scales up when needed
- Rolls back failed deployments

---

## 📊 **MONITORING SETUP**

### 1. Enable Cloud Monitoring

```bash
# Enable APIs
gcloud services enable \
  monitoring.googleapis.com \
  logging.googleapis.com \
  cloudtrace.googleapis.com

# Create notification channel (email)
gcloud alpha monitoring channels create \
  --display-name="Real Estate Intelligence Alerts" \
  --type=email \
  --channel-labels=email_address=your-email@example.com
```

### 2. Create Uptime Checks

```bash
# Create uptime check for health endpoint
gcloud monitoring uptime-checks create https real-estate-intelligence-health \
  --display-name="Real Estate Intelligence Health Check" \
  --resource-type=cloud-run \
  --resource-labels=service=real-estate-intelligence,region=us-east1 \
  --timeout=10s \
  --check-interval=60s \
  --path=/health

# Create alert policy for uptime check failures
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="Real Estate Intelligence - Service Down" \
  --condition-display-name="Health check failing" \
  --condition-threshold-value=1 \
  --condition-threshold-duration=300s \
  --condition-combiner=OR
```

---

## 🚨 **ALERTING POLICIES**

### High Error Rate Alert
```bash
gcloud alpha monitoring policies create \
  --display-name="Real Estate Intelligence - High Error Rate" \
  --condition-display-name="5xx errors above threshold" \
  --condition-threshold-value=10 \
  --condition-threshold-duration=300s \
  --condition-filter='
    resource.type="cloud_run_revision"
    AND resource.labels.service_name="real-estate-intelligence"
    AND metric.type="run.googleapis.com/request_count"
    AND metric.labels.response_code_class="5xx"
  '
```

### High Memory Usage Alert
```bash
gcloud alpha monitoring policies create \
  --display-name="Real Estate Intelligence - High Memory Usage" \
  --condition-display-name="Memory usage above 80%" \
  --condition-threshold-value=0.8 \
  --condition-threshold-duration=300s \
  --condition-filter='
    resource.type="cloud_run_revision"
    AND resource.labels.service_name="real-estate-intelligence"
    AND metric.type="run.googleapis.com/container/memory/utilizations"
  '
```

### Slow Response Time Alert
```bash
gcloud alpha monitoring policies create \
  --display-name="Real Estate Intelligence - Slow Response Time" \
  --condition-display-name="95th percentile latency above 2000ms" \
  --condition-threshold-value=2000 \
  --condition-threshold-duration=300s \
  --condition-filter='
    resource.type="cloud_run_revision"
    AND resource.labels.service_name="real-estate-intelligence"
    AND metric.type="run.googleapis.com/request_latencies"
  '
```

---

## 📈 **CUSTOM METRICS**

Add to your application code for enhanced monitoring:

```javascript
// Example: Track AI query performance
const { MetricServiceClient } = require('@google-cloud/monitoring');
const client = new MetricServiceClient();

async function recordAIQueryMetric(duration, success) {
  const projectId = 'infinity-x-one-systems';
  const projectName = client.projectPath(projectId);
  
  const dataPoint = {
    interval: {
      endTime: {
        seconds: Date.now() / 1000,
      },
    },
    value: {
      doubleValue: duration,
    },
  };
  
  const timeSeriesData = {
    metric: {
      type: 'custom.googleapis.com/ai_query_duration',
      labels: {
        success: success.toString(),
      },
    },
    resource: {
      type: 'cloud_run_revision',
      labels: {
        service_name: 'real-estate-intelligence',
        location: 'us-east1',
      },
    },
    points: [dataPoint],
  };
  
  const request = {
    name: projectName,
    timeSeries: [timeSeriesData],
  };
  
  await client.createTimeSeries(request);
}
```

---

## 🔄 **AUTO-ROLLBACK**

Configure automatic rollback on deployment failure:

```yaml
# Add to .github/workflows/deploy-production.yml
- name: Deploy with auto-rollback
  run: |
    gcloud run deploy real-estate-intelligence \
      --image=$IMAGE \
      --region=us-east1 \
      --no-traffic \
      --tag=candidate
    
    # Test the candidate revision
    CANDIDATE_URL=$(gcloud run services describe real-estate-intelligence \
      --region=us-east1 \
      --format='value(status.traffic[0].url)')
    
    # Run health check
    if curl -f $CANDIDATE_URL/health; then
      echo "✅ Health check passed, promoting to production"
      gcloud run services update-traffic real-estate-intelligence \
        --region=us-east1 \
        --to-latest
    else
      echo "❌ Health check failed, rolling back"
      gcloud run services update-traffic real-estate-intelligence \
        --region=us-east1 \
        --to-revisions=CURRENT=100
      exit 1
    fi
```

---

## 📊 **DASHBOARD SETUP**

### 1. Create Custom Dashboard

```bash
# Create monitoring dashboard
cat > dashboard.json <<EOF
{
  "displayName": "Real Estate Intelligence - Production",
  "mosaicLayout": {
    "columns": 12,
    "tiles": [
      {
        "width": 6,
        "height": 4,
        "widget": {
          "title": "Request Rate",
          "xyChart": {
            "dataSets": [{
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "resource.type=\"cloud_run_revision\" resource.labels.service_name=\"real-estate-intelligence\" metric.type=\"run.googleapis.com/request_count\""
                }
              }
            }]
          }
        }
      },
      {
        "width": 6,
        "height": 4,
        "widget": {
          "title": "Error Rate",
          "xyChart": {
            "dataSets": [{
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "resource.type=\"cloud_run_revision\" resource.labels.service_name=\"real-estate-intelligence\" metric.type=\"run.googleapis.com/request_count\" metric.labels.response_code_class=\"5xx\""
                }
              }
            }]
          }
        }
      },
      {
        "width": 6,
        "height": 4,
        "widget": {
          "title": "Response Time (95th percentile)",
          "xyChart": {
            "dataSets": [{
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "resource.type=\"cloud_run_revision\" resource.labels.service_name=\"real-estate-intelligence\" metric.type=\"run.googleapis.com/request_latencies\""
                }
              }
            }]
          }
        }
      },
      {
        "width": 6,
        "height": 4,
        "widget": {
          "title": "Memory Utilization",
          "xyChart": {
            "dataSets": [{
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "resource.type=\"cloud_run_revision\" resource.labels.service_name=\"real-estate-intelligence\" metric.type=\"run.googleapis.com/container/memory/utilizations\""
                }
              }
            }]
          }
        }
      }
    ]
  }
}
EOF

gcloud monitoring dashboards create --config-from-file=dashboard.json
```

### 2. Access Dashboard

```bash
# Get dashboard URL
open "https://console.cloud.google.com/monitoring/dashboards?project=infinity-x-one-systems"
```

---

## 🔍 **LOG ANALYSIS**

### View Live Logs
```bash
# Real-time logs
gcloud run services logs tail real-estate-intelligence --region=us-east1

# Filter for errors
gcloud run services logs read real-estate-intelligence \
  --region=us-east1 \
  --filter="severity>=ERROR" \
  --limit=50
```

### Log-based Metrics
```bash
# Create log-based metric for AI query errors
gcloud logging metrics create ai_query_errors \
  --description="Count of AI query errors" \
  --log-filter='
    resource.type="cloud_run_revision"
    resource.labels.service_name="real-estate-intelligence"
    jsonPayload.message=~"AI Query Error"
  '
```

---

## 🛡️ **SECURITY MONITORING**

### Enable Cloud Armor (DDoS Protection)
```bash
# Create security policy
gcloud compute security-policies create real-estate-intelligence-policy \
  --description="Security policy for Real Estate Intelligence"

# Add rate limiting rule
gcloud compute security-policies rules create 1000 \
  --security-policy=real-estate-intelligence-policy \
  --expression="true" \
  --action="rate-based-ban" \
  --rate-limit-threshold-count=100 \
  --rate-limit-threshold-interval-sec=60 \
  --ban-duration-sec=600
```

### Enable Audit Logging
```bash
# Enable admin activity logs
gcloud projects add-iam-policy-binding infinity-x-one-systems \
  --member="serviceAccount:infinity-x-one-systems@infinity-x-one-systems.iam.gserviceaccount.com" \
  --role="roles/logging.admin"
```

---

## 📱 **SLACK NOTIFICATIONS** (Optional)

### 1. Create Slack Webhook

1. Go to: https://api.slack.com/messaging/webhooks
2. Create a new webhook for your workspace
3. Copy the webhook URL

### 2. Add to GitHub Actions

```yaml
# Add to .github/workflows/deploy-production.yml
- name: Notify Slack on Success
  if: success()
  uses: slackapi/slack-github-action@v1
  with:
    payload: |
      {
        "text": "✅ Production deployment successful!",
        "blocks": [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "🚀 *Production Deployment Complete*\n\n*Service:* Real Estate Intelligence\n*Status:* ✅ Success\n*URL:* ${{ steps.get-url.outputs.SERVICE_URL }}"
            }
          }
        ]
      }
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

---

## 🎯 **MONITORING CHECKLIST**

✅ Cloud Monitoring enabled  
✅ Uptime checks configured  
✅ Alert policies created  
✅ Dashboard created  
✅ Log-based metrics configured  
✅ Error tracking enabled  
✅ Performance monitoring active  
✅ Security monitoring enabled  
✅ Notification channels configured  
✅ Auto-rollback configured  

---

## 📊 **MONITORING ENDPOINTS**

Access your monitoring dashboards:

- **Cloud Run Metrics:** https://console.cloud.google.com/run/detail/us-east1/real-estate-intelligence/metrics
- **Cloud Monitoring:** https://console.cloud.google.com/monitoring
- **Cloud Logging:** https://console.cloud.google.com/logs
- **Cloud Trace:** https://console.cloud.google.com/traces

---

Your system now has **enterprise-grade monitoring** with **automatic healing**! 🛡️
