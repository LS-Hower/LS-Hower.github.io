#lang racket

(require "../tools/notation.rkt")

(provide page)

(define page
  (document
    (metadata
      #:title "我的其他项目"
      #:numbered #t)
    (section "编程语言 Scheme"
      (section "SICP 解题集"
        (paragraph "在线阅读：" (hyperlink "链接" "https://ls-hower.cc/sicp-solutions/"))
        (paragraph "此网页属于另一 GitHub 仓库。仓库链接：" (hyperlink "sicp-solutions" "https://github.com/LS-Hower/sicp-solutions"))
        (paragraph "对计算机领域经典入门级教科书《计算机程序的构造和解释》（" (italic "Structure and Interpretation of Computer Programs") "，简称 " (italic "SICP") "）课后习题的解答。"))
      (section "数据导向的 Scheme 教程"
        (paragraph "在线阅读：" (hyperlink "链接" "https://ls-hower.cc/scheme-tutorial/"))
        (paragraph "此网页属于另一 GitHub 仓库。仓库链接：" (hyperlink "scheme-tutorial" "https://github.com/LS-Hower/scheme-tutorial"))
        (paragraph "Scheme 编程语言的入门教程。")))
    (section "其他"
      (section "北邮 2025 年春计科转专业机试题"
        (paragraph "在线阅读：" (hyperlink "链接" "https://ls-hower.cc/bupt-major-switching-programming-questions/"))
        (paragraph "此网页属于另一 GitHub 仓库。仓库链接：" (hyperlink "bupt-major-switching-programming-questions" "https://github.com/LS-Hower/bupt-major-switching-programming-questions"))
        (paragraph "北京邮电大学 2025 年年初转专业机试部分编程题的题目、解答和解析。是转入计算机学院的机试题。")))))
