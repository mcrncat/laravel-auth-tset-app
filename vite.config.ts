import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'resources/js'), // LaravelのReactコードがある場所に合わせる
    }
  },
  build: {
    outDir: 'public/build',
    emptyOutDir: true,
    rollupOptions: {
      input: 'resources/js/app.jsx', // メインのエントリーポイントだけ指定
    },
    manifest: true
  },
  // index.htmlを生成しない設定（Inertiaの場合）
  root: '.', 
  publicDir: false, 
  base: '/build/',
})
