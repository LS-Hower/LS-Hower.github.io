#lang racket

(require "../generate-tools.rkt")

(provide page)

(define page
  (document
   (metadata
    #:title "砍掉重练"
    #:publish-date (day-date 2023 8 20))
   (paragraph
    "不想用 Jekyll，所以就在这里手敲 HTML 好了（）")))
