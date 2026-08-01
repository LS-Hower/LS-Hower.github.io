#lang racket

(require "../generate-tools.rkt")

(provide page)

(define page
  (document
   (metadata
    #:title "灵格斯"
    #:publish-date (day-date 2024 8 19))
   (paragraph
    "这两天捣鼓新笔记本电脑。")
   (paragraph
    "前天，下载安装词典软件灵格斯的时候，我发现它上一次更新是在刚好十年零一天之前……那是 2014 年 8 月 16 日。")))
