/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/views/**/*.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        'galaxy-dark': '#0a0a0a',
        'galaxy-panel': '#1a1a2e',
        'galaxy-accent': '#00d4ff',
        'galaxy-secondary': '#9d4edd',
        'galaxy-text': '#e0e0e0',
        'galaxy-text-dim': '#8892b0',
        'galaxy-success': '#06ffa5',
        'galaxy-warning': '#ffd60a',
        'galaxy-danger': '#ff006e',
        // EVE Dashboard palette (reference for consistency)
        'eve-line': '#2a333d',
        'eve-text': '#d8dee6',
        'eve-muted': '#8a97a6',
        'eve-accent': '#4aa8ff',
        'eve-green': '#3fb950',
        'eve-red': '#f85149',
        'eve-gold': '#e3b341',
        // Galaxy Game neon accents
        'neon-cyan': '#00d9ff',
        'neon-purple': '#b366ff',
        'neon-gold': '#ffd700',
      },
      backgroundColor: {
        'glass': 'rgba(22, 27, 33, 0.6)',
      },
      borderColor: {
        'glass': 'rgba(74, 168, 255, 0.2)',
      },
    },
  },
  plugins: [],
}
