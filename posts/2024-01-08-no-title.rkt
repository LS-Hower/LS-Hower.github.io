#lang racket

(require "../generate-tools.rkt")

(provide page)

(define page
  (document
   (metadata
    #:title "无题"
    #:publish-date (day-date 2024 1 8))
   (paragraph
    "我依稀记得自己曾经说过要在 10 月把新的扩展区汉字五笔码表做完。")
   (paragraph
    "看了一下时间，现在是 1 月，时间还是很充裕的（逃）")))
