# LS_Hower 的个人网站

页面链接：

- [`call-cc.cc`](https://call-cc.cc/)

## 构建

### 环境要求

- [Racket](https://racket-lang.org/) 。

### 命令

仓库根目录：

```bash
racket tools/build.rkt
```

### 数据流向

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

## 部署

### 环境要求

- [Racket](https://racket-lang.org/) 。

### 命令

仓库根目录：

```bash
racket tools/deploy.rkt
```

### 数据流向

部署命令会构建站点，并把发布内容以单个提交强推到 `origin` 的 `gh-pages` 分支。发布内容如下：

- `index.html`
- `blog/`
- `site/`
- `main.css`
- `favicon.ico`
- `CNAME`
- `assets/`

源码位于 `main` 分支，构建产物位于 `gh-pages` 分支。在 `main` 分支中，主要的构建产物都写入 `.gitignore` 了：

- `index.html`
- `blog/`
- `site/`

### 说明

网站基于 GitHub Pages 部署。
