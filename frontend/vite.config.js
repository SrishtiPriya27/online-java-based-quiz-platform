import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    proxy: {
      '/quizweb/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
        secure: false,
        // Optional: rewrite if needed
        // rewrite: (path) => path.replace(/^\/quizweb\/api/, '/api')
      }
    }
  }
})
