import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  base: process.env.VITE_BASE_PATH || '/manage/',
  plugins: [react()],
  server: {
    port: 5174,
    hmr: {
      path: '/manage/__vite_ws',
    },
  },
})
