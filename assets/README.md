## 图片转换

由 `gan.svg` 生成 `gan.png` 。指令如下：

```Bash
inkscape --export-width=1440 gan.svg -o gan.png
```

由 `gan.png` 生成 `../favicon.ico` 。指令如下：

```Bash
magick -define icon:auto-resize=256,128,48,32,16 gan.png ../favicon.ico
```

ImageMagick 也可以直接从 `.svg` 生成 `.ico` ，但是文字会错位。

## 软件和字体

### Inkscape

版本： `Inkscape 1.4.2 (f4327f4, 2025-05-13)`

网址： [`https://inkscape.org/`](https://inkscape.org/)

### ImageMagick

版本： `ImageMagick 7.1.1-43 Q16-HDRI x64 a2d96f4:20241222`

网址： [`https://imagemagick.org/`](https://imagemagick.org/)

### 字体“霞鹜文楷 GB”

版本： `Version 1.330;April 28, 2024`

网址： [`lxgw/LxgwWenkaiGB`](https://github.com/lxgw/LxgwWenkaiGB)
