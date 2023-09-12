var elements = [
  {
    "name": "ptw-cwl-clock",
    "js": "/assets/js/ptw-cwl/clock.js"
  }
];

  elements.forEach(function(element) {
    if (document.querySelector(element.name)) {
      var script = document.createElement('script');
      script.type = 'module';
      script.src = element.js;
      document.head.appendChild(script);
    }
  });