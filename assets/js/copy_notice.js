        document.addEventListener('copy', function (e) {
                var copiedText = "————————————————\n\n"
                            + "版权声明：本文作者「ptw-cwl」，转载请附上原文出处链接及本声明。\n\n"
                            + "原文链接：" + window.location.href + "\n\n"
                            + "了解更多信息，请访问我的网站：https://ptw-cwl.gitee.io 或 https://ptw-cwl.github.io";

            if (window.getSelection) {
                var selectedText = window.getSelection().toString();
                if (selectedText) {
                    var modifiedText =  selectedText + "\n\n" + copiedText;
                    e.clipboardData.setData('text/plain', modifiedText);
                    e.preventDefault();
                }
            }
        });