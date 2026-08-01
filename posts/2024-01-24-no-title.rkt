#lang racket

(require "../tools/notation.rkt")

(provide page)

(define page
  (document
   (metadata
    #:title "无题"
    #:publish-date (day-date 2024 1 24))
   (paragraph
    "唉。每次都是不到最后一两个小时就不知道要把该做的待办做完。已经有几个月都是这样了。只是因为自己懒，所以待办做不完。希望以后不要这样。")
   (paragraph
    "还在听 Endless night（东方二创曲，来自专辑 TOHO EURO FLASH Vol.2（"
    (hyperlink
     "THBWiki"
     "https://thwiki.cc/TOHO_EURO_FLASH_Vol.2")
    "））。Eurobeat 风格的歌真好听。")
   (paragraph "待办里有一项是要我把曾经写的一点和数字有关的东西写到博客上。还是算了吧（）")))
