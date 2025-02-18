// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "chartkick/highcharts"
import "./controllers"

// import "bulma-switch"

// app/javascript/application.js
document.addEventListener('turbo:load', () => {
    console.log('Cała strona została załadowana!');
  });
  
  document.addEventListener('turbo:frame-load', () => {
    console.log('Frame został załadowany!');
  });

console.log('HI :)');