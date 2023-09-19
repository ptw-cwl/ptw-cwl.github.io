const multiple = 20;
const mouseOverContainer = document.getElementsByTagName("body")[0];
const element = document.getElementById("preserve-3d");

function transformElement(x, y) {
  let box = element.getBoundingClientRect();
  let calcX = -(y - box.y - (box.height / 2)) / multiple;
  let calcY = (x - box.x - (box.width / 2)) / multiple;
  
  element.style.transform  = "rotateX("+ calcX +"deg) "
                        + "rotateY("+ calcY +"deg)";
}

mouseOverContainer.addEventListener('mousemove', (e) => {
  window.requestAnimationFrame(function(){
    transformElement(e.clientX, e.clientY);
  });
});

mouseOverContainer.addEventListener('mouseleave', (e) => {
  window.requestAnimationFrame(function(){
    element.style.transform = "rotateX(0) rotateY(0)";
  });
});

/*
作者: ptw-cwl
个人网站: ptw-cwl.com
如有侵权，请联系删除。
*/