#lang racket

(require "../tools/notation.rkt")

(provide page)

(define page
  (document
   (metadata
    #:title "友情链接"
    #:numbered #f)
   (section
    "博客"
    (itemize
     (hyperlink "Topology2333" "https://topology2333.github.io/blog/")
     (hyperlink "Auceptin" "https://aucept.in/")
     (hyperlink "_WA自动机" "https://wa-automaton.github.io/")
     (hyperlink "Random Fly" "https://randfly.site/")
     (hyperlink "libfsx" "https://blog.libfsx.org/")
     (hyperlink "zaochen" "https://zaochen.netlify.app/")
     (hyperlink "Fisher4124" "https://fisher4124.github.io/")
     (hyperlink "GBYUJG" "https://kaku.1212967.xyz/")
     (hyperlink "1212967" "https://1212967.xyz/blog/")
     (hyperlink "莉莉图书馆" "http://whitelibrary.voin.ink/")))))
