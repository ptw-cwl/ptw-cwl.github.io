---
title: "我的第一篇博客"
date: 2026-08-14
tags: ["随笔"]
draft: false
---

欢迎来到我的个人博客！这里是使用 [Hugo](https://gohugo.io/) 从零构建的站点，没有使用任何现成主题。

## 为什么自己搭？

- 完全掌控页面结构和样式
- 轻量、无多余依赖
- 学习 Hugo 模板系统的绝佳机会

## 如何写新文章

在项目根目录执行（本机 Hugo 路径）：

```bash
D:\app\hugo_0.165.0_windows-amd64\hugo.exe new posts/my-new-post.md
```

然后编辑 `content/posts/my-new-post.md`，写完执行：

```bash
D:\app\hugo_0.165.0_windows-amd64\hugo.exe server -D   # 本地预览
D:\app\hugo_0.165.0_windows-amd64\hugo.exe             # 生成静态文件到 public/
```

推送到 GitHub 后，Actions 会自动构建并部署到线上。
