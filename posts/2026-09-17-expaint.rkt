#lang racket

(require "../tools/notation.rkt")

(provide page)

(define page
  (document
    (metadata
      #:title "梦境 | 五个字符的 expaint"
      #:publish-date (day-date 2026 9 17))
      (paragraph "阙。")
      (paragraph "是的，指针当然表现得像有符号数一样。")
      (paragraph "于是我试着点开 jajuju 发的代码中，长度只有五个字符的" (code-inline "expaint") "函数名，去一探" (code-inline "offsetof") "的究竟。")
      (paragraph "但它是红色的，点不开。")
      (section "醒了过来"
        (paragraph "打开" (code-inline "cppreference") "试着查找……等等，不用找了。" (code-inline "offsetof") "返回的是偏移量不是差，返回类型肯定是" (code-inline "size_t") "而不是什么" (code-inline "offset_t") "。有符号的东西是" (code-inline "ptrdiff_t") "。"))))
