<template>
  <TopNav />
  <router-view
    :orders="orders"
    :products="products"
    @fetchOrders="fetchOrders"
    @completeOrder="completeOrder"
    @addProductsToList="addProductsToList"
    @updateProductInList="updateProductInList"
    @getProduct="getProduct"
    @getProducts="getProducts"
  ></router-view>
</template>

<script>
import TopNav from './components/TopNav.vue';
import { trackCustomAction, trackError, addTiming } from './datadog-rum';

const productServiceUrl = "/products/";
const singleProductServiceUrl = "/product/";
const makelineServiceUrl = "/makeline/";

export default {
  name: 'App',
  components: {
    TopNav
  },
  data() {
    return {
      orders: [],
      products: [],
      product: {}
    }
  },
  mounted() {
    this.getProducts();
  },
  methods: {
    async addProductsToList(newProduct) {
      this.products.push(newProduct);
      trackCustomAction('product_added', {
        product_id: newProduct.id,
        product_name: newProduct.name
      });
    },
    async updateProductInList(updatedProduct) {
      const index = this.products.findIndex(product => product.id === updatedProduct.id);
      this.products[index] = updatedProduct;
      trackCustomAction('product_updated', {
        product_id: updatedProduct.id,
        product_name: updatedProduct.name
      });
    },
    async getProduct(id) {
      const startTime = performance.now();
      
      fetch(`${singleProductServiceUrl}${id}`)
        .then(response => response.json())
        .then(product => {
          this.product.id = product.id
          this.product.name = product.name
          this.product.image = product.image
          this.product.description = product.description
          this.product.price = product.price
          
          const duration = performance.now() - startTime;
          trackCustomAction('product_fetched', {
            product_id: id,
            duration_ms: Math.round(duration)
          });
        })
        .catch(error => {
          console.log(error)
          trackError(error, {
            action: 'get_product',
            product_id: id
          });
          alert('Error occurred while fetching product')
        })
    },
    async getProducts() {
      const startTime = performance.now();
      
      fetch(`${productServiceUrl}`)
        .then(response => response.json())
        .then(products => {
          this.products = products
          
          const duration = performance.now() - startTime;
          trackCustomAction('products_loaded', {
            count: products.length,
            duration_ms: Math.round(duration)
          });
          
          addTiming('products_loaded');
        })
        .catch(error => {
          console.log(error)
          trackError(error, {
            action: 'get_products'
          });
          alert('Error occurred while fetching products')
        })
    },
    async fetchOrders() {
      const startTime = performance.now();
      
      await fetch(`${makelineServiceUrl}order/fetch`)
        .then(response => response.json())
        .then(data => {
          console.log(data)
          if (data) {
            this.orders = data;
            
            const duration = performance.now() - startTime;
            trackCustomAction('orders_fetched', {
              count: data.length,
              duration_ms: Math.round(duration)
            });
          } else {
            console.log('No orders from server');
          }
        })
        .catch(error => {
          console.error(error);
          trackError(error, {
            action: 'fetch_orders'
          });
        });
    },
    async completeOrder(orderId) {      
      const startTime = performance.now();
      
      // get the order and update the status
      let order = this.orders.find(order => order.orderId === orderId);
      order.status = 1;

      let orderObject = JSON.stringify(order)
      console.log(orderObject);

      await fetch(`${makelineServiceUrl}order`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json'
        },
        body: orderObject
      })
        .then(response => {
          if (!response.ok) {
            alert('Error occurred while processing order')
            trackError(new Error('Order processing failed'), {
              action: 'complete_order',
              order_id: orderId,
              status_code: response.status
            });
          } else {
            alert('Order successfully processed')
            
            const duration = performance.now() - startTime;
            trackCustomAction('order_completed', {
              order_id: orderId,
              duration_ms: Math.round(duration)
            });
            
            // remove the order from the list
            this.orders = this.orders.filter(order => order.orderId !== orderId);
            this.$router.go(-1);
          }
        })
        .catch(error => {
          console.log(error)
          trackError(error, {
            action: 'complete_order',
            order_id: orderId
          });
          alert('Error occurred while processing order')
        })
    }
  },
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 120px;
  padding: 1rem;
}

footer {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background-color: #333;
  color: #fff;
  padding: 1rem;
  margin: 0;
}

nav {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

ul {
  display: flex;
  list-style: none;
  margin: 0;
  padding: 0;
}

li {
  margin: 0 1rem;
}

a {
  color: #fff;
  text-decoration: none;
}

table {
  width: 100%;
  border-collapse: collapse;
  border-spacing: 0;
}

th,
td {
  padding: 8px;
  text-align: left;
  border-bottom: 1px solid #ddd;
}

.order-detail {
  text-align: left;
}

button {
  padding: 10px;
  background-color: #005f8b;
  color: #fff;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  height: 42px;
}

button:hover {
  background-color: #005f8b;
}

.action-button {
  float: right;
}

.product-detail {
  text-align: left;
  display: flex;
  align-items: flex-start;
  justify-content: center;
  gap: 1rem;
  margin: 2rem auto;
}

.product-form {
  display: flex;
  flex-direction: column;
  align-items: left;
  justify-content: center;
  margin: 2rem auto;
  width: 50%;
}

.form-row {
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 10px;
}

.ai-button {
  margin-left: 10px;
  padding: 10px 10px;
  border-radius: 5px;
  border: none;
  background-color: #007acc;
  color: #fff;
  cursor: pointer;
}

.ai-button:hover {
  background-color: #005f8b;
}

textarea {
  width: 100%;
  padding: 5px;
  border-radius: 5px;
  border: 1px solid #ccc;
}

label {
  text-align: right;
  margin-right: 10px;
  width: 100px;
  font-weight: bold;
}

input {
  width: 100%;
  padding: 5px;
  border-radius: 5px;
  border: 1px solid #ccc;
}
</style>