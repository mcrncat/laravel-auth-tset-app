import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')

  return {
    plugins: [react()],
    resolve: {
      alias: {
        '@': path.resolve(__dirname, 'resources/js'),
      }
    },
    build: {
      outDir: 'public/build',
      emptyOutDir: true,
      rollupOptions: {
        input: 'resources/js/app.jsx',
      },
      manifest: true
    },
    root: '.',
    publicDir: false,
    base: `${env.VITE_APP_URL}/build/`, // ← HTTPS URLを明示
  }
})
