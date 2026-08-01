#lang racket

(require "../tools/notation.rkt")

(provide page)

(define page
  (document
   (metadata
    #:title "关于本站"
    #:numbered #f)
   (paragraph
    "本站目前是使用自制框架生成的。")
   (paragraph
    (hyperlink
     "本站 GitHub 仓库"
     "https://github.com/LS-Hower/LS-Hower.github.io"))))
