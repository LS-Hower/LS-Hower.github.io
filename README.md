# LS-Hower.github.io

LS Hower 的个人页面，通过 GitHub Pages 搭建。

[页面链接](https://ls-hower.github.io/)

## 构建

### 环境要求

- [Racket](https://racket-lang.org/) 。
- 部分文章所需要的 Python 环境和一些三方库。具体地，只有 `2026-08-02-divmod` 这一篇文章。将来会移除这一要求。

### 命令

仓库根目录：

```bash
racket tools/build.rkt
```

### 文件

页面：

- 文章页： `posts/*.rkt` 编译至 `blog/*.html` 。
    - 特别地，示例代码 `posts/example.rkt` 不编译。
- 站点页： `pages/*.rkt` 编译至 `site/*.html` 。
    - 特别地，首页： `pages/index.rkt` 编译至 `index.html` 。

（构建前会先清理。）

其他：

- 图片、代码等资源： `assets/`
- 图标： `favicon.ico`
- 样式： `main.css`

### 说明

文章页与站点页使用一种基于 Racket 的表记方法写成，它们的源代码也是合法的 Racket 源代码。至于用法，没有文档，源代码先凑合着看吧： `tools/notation.rkt` 。
