use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt, EnvFilter};
use opentelemetry::sdk::trace;
use opentelemetry::sdk::Resource;
use opentelemetry::KeyValue;
use opentelemetry::runtime::Tokio;
use std::env;

pub fn init_tracing() {
    let dd_service = env::var("DD_SERVICE").unwrap_or_else(|_| "product-service".to_string());
    let dd_env = env::var("DD_ENV").unwrap_or_else(|_| "production".to_string());
    let dd_version = env::var("DD_VERSION").unwrap_or_else(|_| "1.0.0".to_string());
    let dd_agent_host = env::var("DD_AGENT_HOST").unwrap_or_else(|_| "127.0.0.1".to_string());
    
    log::info!("DD APM: service={}, env={}, version={}, agent={}", 
        dd_service, dd_env, dd_version, dd_agent_host);

    // Try to create Datadog exporter with Tokio runtime
    let tracer_result = opentelemetry_datadog::new_pipeline()
        .with_service_name(&dd_service)
        .with_agent_endpoint(format!("http://{}:8126", dd_agent_host))
        .with_trace_config(
            trace::config().with_resource(Resource::new(vec![
                KeyValue::new("service.name", dd_service.clone()),
                KeyValue::new("deployment.environment", dd_env),
                KeyValue::new("service.version", dd_version),
            ]))
        )
        .install_batch(Tokio);

    match tracer_result {
        Ok(tracer) => {
            log::info!("Datadog APM initialized successfully");
            
            // Set up tracing subscriber with OpenTelemetry layer
            let telemetry = tracing_opentelemetry::layer().with_tracer(tracer);
            
            tracing_subscriber::registry()
                .with(EnvFilter::new(
                    env::var("RUST_LOG").unwrap_or_else(|_| "info".into()),
                ))
                .with(tracing_subscriber::fmt::layer())
                .with(telemetry)
                .init();
        }
        Err(e) => {
            log::warn!("Failed to initialize Datadog tracer: {}, continuing with basic tracing", e);
            
            // Fall back to basic tracing without OpenTelemetry
            tracing_subscriber::registry()
                .with(EnvFilter::new(
                    env::var("RUST_LOG").unwrap_or_else(|_| "info".into()),
                ))
                .with(tracing_subscriber::fmt::layer())
                .init();
        }
    }
}