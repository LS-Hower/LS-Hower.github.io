#lang racket

(require "../tools/notation.rkt")

(provide page)

(define page
  (document
   (metadata
    #:title "禾"
    #:publish-date (day-date 2026 8 30)
    #:math 'katex)
   (section "换框架"
    (paragraph "一个月前还是开始觉得手写 HTML 有点麻烦了，于是又想着用博客框架了，于是尝试了一下" (hyperlink "Hexo" "https://hexo.io") "。选它是因为看到了一款观感不错的简约主题。但折腾了一天发现还是不尽如人意。")
    (paragraph "于是我还是决定自己造一个博客生成框架。第一步是找一个表示方式，来将自己之前的那些博客和页面里的数据重写一下，可选的有 Markdown 和 HTML 甚至 JSON 等等。我这半年信仰 Scheme，于是选择了 S-表达式。我甚至感觉它会很通用。")
    (paragraph "页面生成器是我让 AI 写的。我因为太懒所以甚至刚好完全落实了“代码一眼不看”的所谓“Vibe Coding 的宗旨”。不知道现在代码是怎么样一个情况。其实一直有一种“不是自己的东西”的感觉。至少之后必须把代码重构几次。此外当然它的功能还很少，还很可能有大量缺陷。至少现在就有一些功能我想加上，比如博客类别和标签系统。")
    (paragraph "现在这个网站更好看了一些，还是挺不错的。"))
   ; TODO：页面间互相引用
   (section "带余除法策略"
    (paragraph "正是因为这篇文章里大量使用" ($ "\\LaTeX") "，还使用了列表、表格代码块，我才有动力真的不再手写 HTML 而是用框架了。这算是直接原因。")
    (paragraph "页面生成器还应当拥有将我的页面转换成其他表示（比如 Markdown）的能力。也就是说，要有 Markdown 渲染器。这样我就可以在其他平台同步上传文章了。")
    (paragraph "哦对了，发布完后不久发现里面的基于无条件控制余数符号的策略似乎还是有机会优雅自然地扩展到复数域的，之后还得改。")
    (paragraph "这篇文章也是我这个博客里第一篇讲知识的文章，在此之前，这里的博客都只是网络日记。画风有点不太对。这也是为什么应该尽快做一个文章类别系统。"))
   (section "新域名"
    ; TODO：添加“字面的 URL”
    (paragraph "买了一个域名" (hyperlink (code-inline "ls-hower.cc") "https://ls-hower.cc") "，现在用在本站了。"))))
