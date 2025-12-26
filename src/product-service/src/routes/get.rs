use crate::model::ProductInfo;
use crate::startup::AppState;
use actix_web::{web, Error, HttpResponse};
use tracing::{info_span, instrument};


#[instrument(skip(data, path))]
pub async fn get_product(
    data: web::Data<AppState>,
    path: web::Path<ProductInfo>,
) -> Result<HttpResponse, Error> {

    let _span = info_span!("get_product", product_id = path.product_id).entered();

    let products = data.products.lock().unwrap();

    // find product by id in products
    let index = products
        .iter()
        .position(|p| p.id == path.product_id);
    if let Some(i) = index {
        return Ok(HttpResponse::Ok().json(products[i].clone()))
    }
    else {
        return Ok(HttpResponse::NotFound().body("Product not found"))
    }
}
#[instrument(skip(data))]
pub async fn get_products(data: web::Data<AppState>) -> Result<HttpResponse, Error> {
    let _span = info_span!("get_products").entered();
    let products = data.products.lock().unwrap();
    Ok(HttpResponse::Ok().json(products.to_vec()))
}