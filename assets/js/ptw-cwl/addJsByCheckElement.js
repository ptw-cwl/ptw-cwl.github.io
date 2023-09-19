
var elements = [
  {
    "name": "ptw-cwl-clock",
    "js": "/assets/js/ptw-cwl/clock.js",
    "comment": "作者: ptw-cwl\n个人网站: ptw-cwl.com\n如有侵权，请联系删除。"
  }
];

elements.forEach(function(element) {
  if (document.querySelector(element.name)) {
    var script = document.createElement('script');
    script.type = 'module';
    script.src = element.js;
    script.setAttribute('title', element.comment);
    document.head.appendChild(script);
  }
});

/*
作者: ptw-cwl
个人网站: ptw-cwl.com
如有侵权，请联系删除。
*/