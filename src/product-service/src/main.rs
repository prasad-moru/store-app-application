use product_service::{
    configuration::Settings,
    startup::run
};

mod tracing_setup;

#[actix_web::main]
async fn main() -> std::io::Result<()> {

    let settings = Settings::new()
        .set_wasm_rules_engine(false);

    // Initialize Datadog tracing
    tracing_setup::init_tracing();

    run(settings)?.await
}
