#lang racket

(require "../tools/notation.rkt")

(provide page)

(define page
  (document
    (metadata
      #:title "无法溯源的动物名字"
      #:publish-date (day-date 2026 9 23))
      (paragraph "昨天晚上我脑中突然蹦出 reptiles 这个单词的读音和字样。查了一下，reptile 是爬行动物。")
      (paragraph "今天白天又突现蹦出 bos primi genious 这样的读音和字样。查了一下，Bos primigenius 是原牛。")
      (paragraph "但是查出来不等于能溯源了。我仍然不知道这些词凭什么就蹦出来了。")
      (paragraph "我知道梦境内容是现实内容重组拼贴而成的，比如在现实中吃了柚子又和人在 QQ 上聊了天，那么梦里可能一边吃柚子一边 QQ 聊天。从梦境溯源现实原型还是比较容易的，毕竟梦和现实在脑中都显得那么真实，易于联想。我的脑中突然蹦出我自己都不认识的单词，原理也是类似的，肯定也是因为之前无意中见到它们甚至熟悉了它们。")
      (paragraph "但符号和梦境情节不一样。Reptile 是一个抽象的符号，Bos primigenious 也是。太难溯源了。符号是高度抽象的，一个符号太容易和它出现时的元信息完全甩开关系。符号又是常见的，我们每天都在处理它们，即使发呆时也是。溯源的时候搜索范围太大了。")
      (paragraph "对于有些汉字和词语，刚认识它时我处在什么样的情境中，我倒还是有记忆的。但那毕竟也只是少数。而且我现在竟突然一个例子也举不出来。")
      (paragraph "不过我还是有点琢磨出来刚才那两个词我是在什么地方看到的了。")
      (list-unordered
        "Reptiles 是因为，前些天搜索了埃舍尔的蜥蜴画，它的名字就是 Reptiles。"
        "Bos primigenious 则是因为，QQ 群里有一个群友叫 Bosprimigenious。")
      (image "../assets/reptiles.webp"
             ; TODO: 在这里使用斜体
             #:alt "埃舍尔画作《爬行动物》（Reptiles）"
             #:title "埃舍尔画作《爬行动物》（Reptiles）"
             #:caption "埃舍尔画作《爬行动物》（Reptiles）"
             #:width 30)
      (paragraph "配图来自网站" (hyperlink "爬行动物 | 埃舍爾宮殿" "https://escherinhetpaleis.nl/zh/%E5%85%B3%E4%BA%8E%E5%9F%83%E8%88%8D%E5%B0%94/%E6%9D%B0%E4%BD%9C/%E7%88%AC%E8%A1%8C%E5%8A%A8%E7%89%A9") "。")
      (paragraph "但有没有一些通用的方法帮助我琢磨呢。琢磨得到的结果我想只会是偶然的。我不知道。")))
