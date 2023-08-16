window.onload = function() {
    const containers = document.querySelectorAll('.container');

    containers.forEach(container => {
      const img = container.querySelector('img');
      const containerWidth = container.offsetWidth;
      const containerHeight = container.offsetHeight;
      const imgAspectRatio = img.naturalWidth / img.naturalHeight;

      if (containerWidth / containerHeight > imgAspectRatio) {
		img.style.width = 'auto';
        img.style.height = '100%';

      } else {
        img.style.width = '100%';
        img.style.height = 'auto';
      }
    });
  };