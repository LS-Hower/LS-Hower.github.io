#lang racket

(require "../tools/notation.rkt")

(provide page)

(define page
  (document
   (metadata
    #:title "其他项目"
    #:numbered #t)
   (section
    "编程语言 Scheme"
    (section
     "SICP 解题集"
     (itemize
      (list "在线阅读：" (hyperlink "链接" "https://ls-hower.github.io/sicp-solutions/"))
      (list "此网页属于另一 GitHub 仓库。仓库链接："
            (hyperlink "sicp-solutions" "https://github.com/LS-Hower/sicp-solutions")))
     (paragraph
      "对计算机领域经典入门级教科书《计算机程序的构造和解释》（"
      (italic "Structure and Interpretation of Computer Programs")
      "，简称 "
      (italic "SICP")
      "）课后习题的解答。"))
    (section
     "数据导向的 Scheme 教程"
     (itemize
      (list "在线阅读：" (hyperlink "链接" "https://ls-hower.github.io/scheme-tutorial/"))
      (list "此网页属于另一 GitHub 仓库。仓库链接："
            (hyperlink "scheme-tutorial" "https://github.com/LS-Hower/scheme-tutorial")))
     (paragraph
      "Scheme 编程语言的入门教程。")))
   (section
    "其他"
    (paragraph
     "未定。"))))
