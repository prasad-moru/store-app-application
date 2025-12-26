// src/store-front/src/datadog-rum.js
import { datadogRum } from '@datadog/browser-rum';

export function initDatadogRUM() {
  // Only initialize in production or when explicitly enabled
  const isRumEnabled = process.env.VUE_APP_DATADOG_RUM_ENABLED === 'true';
  
  if (!isRumEnabled) {
    console.log('Datadog RUM is disabled');
    return;
  }

  const applicationId = process.env.VUE_APP_DATADOG_RUM_APPLICATION_ID;
  const clientToken = process.env.VUE_APP_DATADOG_RUM_CLIENT_TOKEN;
  const site = process.env.VUE_APP_DATADOG_SITE || 'us5.datadoghq.com';
  const service = process.env.VUE_APP_DATADOG_SERVICE || 'store-front';
  const env = process.env.VUE_APP_DATADOG_ENV || 'production';
  const version = process.env.VUE_APP_VERSION || '1.0.0';

  if (!applicationId || !clientToken) {
    console.error('Datadog RUM: Missing required configuration (Application ID or Client Token)');
    return;
  }

  datadogRum.init({
    applicationId: applicationId,
    clientToken: clientToken,
    site: site,
    service: service,
    env: env,
    version: version,
    
    // Session sampling
    sessionSampleRate: 100, // 100% of sessions tracked
    sessionReplaySampleRate: 20, // 20% of sessions recorded
    
    // Tracking configuration
    trackUserInteractions: true,
    trackResources: true,
    trackLongTasks: true,
    trackFrustrations: true,
    
    // Default privacy level
    defaultPrivacyLevel: 'mask-user-input',
    
    // Enable console logs collection
    forwardErrorsToLogs: true,
    forwardConsoleLogs: ['error', 'warn'],
    
    // Performance tracking
    trackViewsManually: false, // Auto-track page views
    
    // Enhanced telemetry
    enableExperimentalFeatures: ['clickmap'],
    
    // Allow specific URLs for tracking
    allowedTracingUrls: [
      { match: /https:\/\/.*\.amazonaws\.com/, propagatorTypes: ['tracecontext'] },
      { match: /http:\/\/.*\.svc\.cluster\.local/, propagatorTypes: ['tracecontext'] },
      { match: /\/order.*/, propagatorTypes: ['tracecontext'] },
      { match: /\/products.*/, propagatorTypes: ['tracecontext'] }
    ],

    // Before send hook for data scrubbing
    beforeSend: (event) => {
      // Scrub sensitive data if needed
      if (event.type === 'resource' && event.resource.url.includes('sensitive')) {
        return false; // Don't send this event
      }
      return true;
    }
  });

  // Set global context
  datadogRum.setGlobalContextProperty('app_type', 'customer_portal');
  datadogRum.setGlobalContextProperty('deployment_type', 'kubernetes');
  
  // Start session replay (optional)
  datadogRum.startSessionReplayRecording();

  console.log(`Datadog RUM initialized for ${service} in ${env}`);
}

// Helper function to track custom actions
export function trackCustomAction(actionName, actionContext = {}) {
  if (datadogRum) {
    datadogRum.addAction(actionName, actionContext);
  }
}

// Helper function to track errors
export function trackError(error, errorContext = {}) {
  if (datadogRum) {
    datadogRum.addError(error, errorContext);
  }
}

// Helper function to set user info
export function setUser(userInfo) {
  if (datadogRum && userInfo) {
    datadogRum.setUser({
      id: userInfo.id,
      name: userInfo.name,
      email: userInfo.email,
      // Don't include sensitive information
    });
  }
}

// Helper function to add custom timing
export function addTiming(name) {
  if (datadogRum) {
    datadogRum.addTiming(name);
  }
}