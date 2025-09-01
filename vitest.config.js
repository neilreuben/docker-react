import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: './src/setupTests.js',
    coverage: {
      reporter: ['text', 'json', 'html', 'cobertura'],
      reportsDirectory: './coverage',
      exclude: [
        'node_modules/',
        'src/setupTests.js',
        '**/*.config.js',
        'dist/'
      ]
    },
    // For Jenkins XML output
    reporters: ['default', 'junit'],
    outputFile: {
      junit: './test-results.xml'
    }
  }
})
