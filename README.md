# LS-Hower.github.io

LS Hower 的个人页面，通过 GitHub Pages 搭建。

[页面链接](https://ls-hower.github.io/)

## 构建

需要安装 [Racket](https://racket-lang.org/) 。文章页与站点页使用基于 Racket 的表记方法（见 `tools/notation.rkt`）写成。它们的源代码也是合法的 Racket 源代码。

- `posts/*.rkt` ：文章页源代码
- `pages/*.rkt` ：站点页源代码（含 `index.rkt` ）

在仓库根目录运行：

```
racket tools/build.rkt
```

生成

- `index.html` ：主页
- `blog/*.html` ：文章页
- `site/*.html` ：站点页

构建前会清理这些位置中本次未生成的遗留 `.html` 。
