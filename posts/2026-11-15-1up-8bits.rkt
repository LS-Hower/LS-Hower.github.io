#lang racket

(require "../tools/notation.rkt")

(provide page)

(define page
  (document
    (metadata
      #:title "滚动的天空，硬件，MC"
      #:publish-date (day-date 2026 11 15))
    (section "重玩《滚动的天空》"
      (paragraph "最近重新开始玩《滚动的天空》（RS）了。7 天前通关了像素，这算是我几年以来都想要达成的目标。1 天前通关了它的奖励关 8 比特。")
      (paragraph "我发现 Miraheze 上这个" (hyperlink "滚动的天空 wiki 站" "https://rs.miraheze.org/wiki/Project:%E9%A6%96%E9%A1%B5") "比较不错。")
      (paragraph "我大概是在霓虹版本（1.7.3）前后入坑的，总之是在 2017 年末、2018 年年初。印象里，第一次玩的时候，还玩到了冬日版本（1.7.0）所推出的那个雪花宝箱活动。后来很长一段时间都爱看 RS 视频，同时还有《跳舞的线》和《几何冲刺》。后来兴趣逐渐减少了。2020 年年中 RS 宣布停更的时候就已经是不怎么关注的状态了。2023 年复更的时候有听说，但也没去看了。2025 年年初又玩了一小阵子，并分别做到了天空之城和电子迷宫完美通关，分别是在 2 月 9 日和 2 月 11 日。顺便也看了一眼 RS 圈子，发现比以前癫得多了，不过我还挺喜欢的。现在也是这样。")
      (paragraph "从去年开始就觉得，很多新关卡都比旧五星关什么的难得多了。但无论是官方还是圈子里的个人，他们给出的难度定数往往都不这么认为。我想还是因为曾经看了太多 RS 视频，那些老关我都背熟了。"))
    (section "硬件更新"
      (paragraph "参考朋友的硬件配置，我也购买了多层置物架和更舒适的椅子。还安装了一台显示器。这样可以提升工作、学习、娱乐和生活效率，虽然“效率”这个词疑似不适合用来修饰“娱乐”和“生活”。"))
    (section "MC 视频"
      (paragraph "最近看了三篇实锤 Dream 作弊的视频。")
      (list-unordered
        (list (hyperlink "【精翻熟肉】Dream的猎人游戏到底有没有作弊？我采访了他……（上集）" "https://www.bilibili.com/video/BV1s1pd6bEmN/"))
        (list (hyperlink "【熟肉】Dream“未剪辑”猎人游戏视频也是谎言" "https://www.bilibili.com/video/BV11Sp56yEzu/"))
        (list (hyperlink "【熟肉/Karl Jobst】Dream必须停止撒谎！曾为他洗白的我，这次亲手实锤全部造假" "https://www.bilibili.com/video/BV1dzxN63EMQ/")))
      (paragraph "MC 史上最伟大的 ARG。")
      (paragraph "这两天在看去年火起来的 ARG 系列《寻找不存在的世界》，虽然它严格意义上不算 ARG。写完这个我就要去看第二集了。"))))
