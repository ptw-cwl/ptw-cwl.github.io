# 如何添加网站 Favicon 图标

您可以通过在HTML的`<head>`部分添加一个`<link>`标签来添加网站的`favicon`，也就是网站地址栏旁边显示的小图标。以下是您可以添加到`<head>`部分的代码：

```html
<link rel="shortcut icon" href="/path/favicon.ico" type="image/x-icon" />
```

请将"`/path/favicon.ico`"替换为您实际的favicon图标文件的路径。这样，当您的网站被访问时，大多数现代浏览器都会自动显示这个图标在地址栏旁边。