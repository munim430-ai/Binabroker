/** @type {import('tailwindcss').Config} */
export default {
  darkMode: 'class',
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
      colors: {
        matte: '#121212',
        surface: '#1E1E1E',
        border: '#2A2A2A',
        ocean: '#0A74DA',
        primaryText: '#F3F4F6',
        mutedText: '#9CA3AF',
      },
    },
  },
  plugins: [],
};
