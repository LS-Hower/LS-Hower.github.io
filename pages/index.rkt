#lang racket

(require "../tools/notation.rkt")

(provide page)

(define page
  (document
   (metadata
    #:title "主页"
    #:numbered #f)
   (image "images/gan.png"
          #:alt "常用头像“绀”"
          #:title "常用头像“绀”"
          #:width 300
          #:height 300)
   (paragraph
     "欢迎。")
   (paragraph
    "这是 LS_Hower 的网站。")
   (paragraph
    (hyperlink
     "LS-Hower 的 GitHub 个人资料"
     "https://github.com/LS-Hower"))
   (section
    "最新文章"
    (posts-list))
   (section
    "其他页面"
    (page-links))))
