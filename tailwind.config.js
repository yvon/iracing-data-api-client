/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./templates/**/*.html.erb"],
  theme: {
    extend: {
      fontFamily: {
        'sans': ['Whitaker', '-apple-system', 'BlinkMacSystemFont', 'HelveticaNeue-Light', 'Segoe UI', 'Helvetica Neue', 'Helvetica', 'Raleway', 'Arial', 'sans-serif', 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', '-apple-system', 'BlinkMacSystemFont', 'HelveticaNeue-Light', 'Segoe UI', 'Helvetica Neue', 'Helvetica', 'Raleway', 'Arial', 'sans-serif', 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol']
      }
    }
  },
  plugins: []
};
