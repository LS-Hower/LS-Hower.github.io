#lang racket

(require "../tools/notation.rkt")

(provide page)

(define page
  (document
   (metadata
    #:title "主页"
    #:numbered #f)
   (image "assets/gan.png"
          #:alt "常用头像“绀”"
          #:title "常用头像“绀”"
          #:width 18.75
          #:height 18.75)
   (paragraph "欢迎。")
   (paragraph "这是 LS_Hower 的网站。")
   (section
    "最新文章"
    (posts-list))
   (section
    "其他页面"
    (page-links))
   (section
    "联系方式"
    (itemize
     (list "GitHub 账号：" (hyperlink "LS-Hower" "https://github.com/LS-Hower"))
     (list "QQ 号：" (code-inline "37812535"))
     (list "邮箱：" (hyperlink (code-inline "ls.hower06@gmail.com") "mailto:ls.hower06@gmail.com"))
     (list "邮箱：" (hyperlink (code-inline "ls_hower@qq.com") "mailto:ls_hower@qq.com"))))))
