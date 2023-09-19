 var backToTopButton = document.getElementById("backToTop");

    window.addEventListener("scroll", function() {
        if (window.pageYOffset >= 10) {
            backToTopButton.style.display = "block";
        } else {
            backToTopButton.style.display = "none";
        }
    });

    backToTopButton.addEventListener("click", function() {
        window.scrollTo({
            top: 0,
            behavior: "smooth"
        });
    });


/*
作者: ptw-cwl
个人网站: ptw-cwl.com
如有侵权，请联系删除。
*/