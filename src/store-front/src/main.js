import { createApp } from 'vue'
import router from './router'
import App from './App.vue'
import { initDatadogRUM } from './datadog-rum'

// Initialize Datadog RUM before creating the app
initDatadogRUM()

const app = createApp(App)

// Add router navigation tracking
router.afterEach((to, from) => {
  // Datadog RUM will automatically track route changes
  // You can add custom context here if needed
  if (window.DD_RUM) {
    window.DD_RUM.addAction('route_change', {
      from: from.path,
      to: to.path,
      name: to.name
    })
  }
})

app.use(router).mount('#app')