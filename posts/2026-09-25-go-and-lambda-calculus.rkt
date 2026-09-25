#lang racket

(require "../tools/notation.rkt")

(provide page)

(define page
  (document
    (metadata
      #:title "围棋和 λ 演算"
      #:publish-date (day-date 2026 9 25))
      (paragraph "前段时间观看了" (hyperlink "Numberphile" "https://www.youtube.com/@numberphile") "的视频" (hyperlink "2081681993819799846994786333448627702865224538845305484256394568209274196127380153785256484516 (etc) " "https://www.youtube.com/watch?v=1cvKGqgOx_8") "。这个视频讲解了围棋中的组合数学，并且提到了 John Tromp 这个人。他计算了 19×19 围棋棋盘上所有可能的局势数量，见他的介绍页面" (hyperlink "Number of legal Go positions" "https://tromp.github.io/go/legal.html") "以及论文" (hyperlink "Combinatorics of Go" "https://tromp.github.io/go/gostate.pdf") "。")
      (paragraph "这些天加入了" (hyperlink "Code Golf Stack Exchange 站" "https://codegolf.stackexchange.com/") "，又接触到了一些深奥编程语言，其中一个就是 Binary Lambda Calculus（" (hyperlink "esolangs.org 页面" "https://esolangs.org/wiki/Binary_lambda_calculus") "）。深入探究了一下，发现这款语言竟也是 John Tromp 的作品，是在 2004 年发明的。语言的主页是" (hyperlink "这里" "https://tromp.github.io/cl/Binary_lambda_calculus.html") "。")
      ; TODO：允许在 hyperlink 的显示文字中使用 list
      (paragraph "话说自从从" (hyperlink "Topology2333 学长的博客" "https://topology2333.github.io/blog/posts/pl/de-bruijn-index/") "这里学会了 De Bruijn index 之后，我真的在其他一些地方见到了它的应用，包括这里的 Binary Lambda Calculus 语言。还是很不错的。")))
