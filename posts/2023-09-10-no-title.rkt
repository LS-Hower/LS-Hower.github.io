#lang racket

(require "../generate-tools.rkt")

(provide page)

(define page
  (document
   (metadata
    #:title "无题"
    #:publish-date (day-date 2023 9 10))
   (section
    "一首东方二创曲的 PV"
    (paragraph
     "听"
     "叙聖のクオリア ～Subterranean rose～（"  ;; TODO: 这里使用 Raw HTML
     (hyperlink
      "THBWiki 页面"
      "https://cache.thwiki.cc/%E6%AD%8C%E8%AF%8D:%E5%8F%99%E8%81%96%E3%81%AE%E3%82%AF%E3%82%AA%E3%83%AA%E3%82%A2_%EF%BD%9ESubterranean_rose%EF%BD%9E")
     ("）。不过这首歌的 PV 好像找不到了，我记得几个月前网上还有的。")))
   (section
    "以后学点新东西？"
    (paragraph
     "七天前还和 GBYUJG 聊到，以后有时间了，可能会想，学点绘画或者制作动画和音乐之类的，得到了“这是好的”的评价。")
    (paragraph
     "能有 Blender、Krita、FontForge 这样的开源软件也是好事。但是要用好这些工具就不容易了。")
    (paragraph
     "而现在的我，连一个 RIME 输入法引擎，都弄不明白（"))))
