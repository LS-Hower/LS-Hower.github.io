#lang racket

(require "../tools/notation.rkt")

(provide page)

(define page
  (document
    (metadata
      #:title "游戏，工具，以及 R⁵RS"
      #:publish-date (day-date 2026 11 4))
      (section "游戏"
        (paragraph "这段时间玩了一些游戏。我将" (hyperlink "Nitrome" "https://www.nitrome.com/") "的《高楼爆破》（Rubble Trouble）系列通关了。此外还有《平衡球》（Ballance）。前者是我的童年回忆，后者不是，但也是很多人的童年回忆。")
        (paragraph "平衡球第十三关比前面的关卡要更难。我今天才算是把它比较满意地通关了。具体讲，就是三命全分通关了。最终分数为 1300 + 4832 + 1200 = 7332 分，虽然不高，但已经差不多了。")
        (paragraph "之后也有游戏要玩。"))
      (section "软件"
        (paragraph "这段时间更换了一些工具软件。这里将大部分的记录搬过来：")
        (table
          (header-row (cell "主题") (cell "弃用工具") (cell "新工具") (cell "其他选项"))
          (row (cell "浏览器") (cell "百分（Cent）") (cell "Firefox（火狐）") (cell "Chrome / Edge / Lunascape"))
          (row (cell "QQ 机器人") (cell "") (cell "Napcat + Astrbot") (cell ""))
          (row (cell "管理：应用窗口") (cell "") (cell "United Sets") (cell "TidyTabs / Groupy / WindowTabs"))
          (row (cell "网页浏览体验") (cell "") (cell "Stylus + Tampermonkey") (cell "Stylish"))
          (row (cell "管理：笔记") (cell "Joplin") (cell "VS Code + OneDrive 文件") (cell "GitHub / Obsidian / Logseq / OneNote"))
          (row (cell "截图") (cell "Snipaste") (cell "ShareX") (cell ""))
          (row (cell "管理：待办 (每日|一般)") (cell "Joplin") (cell "Microsoft To Do（微软待办）") (cell "自己做一个"))
          (row (cell "实用工具集") (cell "") (cell "PowerToys") (cell ""))
          (row (cell "管理：磁盘空间") (cell "SpaceSniffer") (cell "WizTree") (cell "")))
        (paragraph "也有一些是决定不更换的，如下表：")
        (table
          (header-row (cell "主题") (cell "原工具") (cell "设想过的新工具"))
          (row (cell "管理：浏览器标签页") (cell "OneTab") (cell "限制标签页数量的扩展程序"))
          (row (cell "RSS 阅读器") (cell "FeedDemon") (cell "Folo / Fluent Reader"))
          (row (cell "听音乐") (cell "网易云音乐") (cell "QQ 音乐"))
          (row (cell "管理：本地文件") (cell "Everything") (cell "Listary")))
        (paragraph "此外，对账号密码信息的管理方式也做了更改。")
        (paragraph "想要找到合适的磁盘清理工具，以及手机存储空间清理工具。但是我没动手去找。"))
      (section "R⁵RS"
        (paragraph "这段时间阅读了 R⁵RS 标准全文。R⁵RS 全称 Revised⁵ Report on the Algorithmic Language Scheme（我觉得不用把 5 个“Revised”一个个写出来），是" (hyperlink "Scheme 编程语言标准" "https://standards.scheme.org/") "中相当经典的一个。")
        (paragraph "我阅读的版本是" (hyperlink "王咏刚的试译稿（《算法语言 Scheme 修订⁵报告》）" "https://math.pku.edu.cn/teachers/qiuzy/progtech/scheme/r5rscn.pdf") "。他在翻译过程中采纳了来自" (hyperlink "裘宗燕" "https://math.pku.edu.cn/teachers/qiuzy/") "的意见和建议，后者正是 SICP（《计算机程序的构造和解释》）的译者。越来越觉得自己的" (hyperlink "SICP 解题集项目" "https://github.com/LS-Hower/sicp-solutions") "得大改一下了。")
        (paragraph "不过还有一些东西没完全理解，但近期我也不打算继续深挖了。这包括：")
        (list-unordered
          (list (hyperlink "7.2 形式语义" "https://standards.scheme.org/corrected-r5rs/r5rs-Z-H-10.html#%_sec_7.2") "全节；")
          (list (hyperlink "3.5 严格尾递归" "https://standards.scheme.org/corrected-r5rs/r5rs-Z-H-6.html#%_sec_3.5") "一节中，rationale 里提及初版 Scheme 及其中的 Actor 的两个段落；")
          (list (code-inline "call-with-current-continuation") "过程的 rationale 中讲解逃逸结构历史的一个段落；")
          ; TODO 这里 of 和 call-with-current-continuation 之间没有空格
          (list (hyperlink "R⁵RS 勘误表" "https://mumble.net/~kelsey/r5rs-errata.html") "中“Semantics of" (code-inline "call-with-current-continuation") "”一节。"))
        (paragraph "这些都不同程度地需要考古工作和/或其他领域知识才能够完全理解。")
        (paragraph "在阅读这篇标准的过程中，为了理解一些个人觉得比较有趣的概念，我倒也确实考过古以及学过其他领域的知识，比如为了理解标准在两个地方都提到过的驻留符号（interned symbol）而考察了" (hyperlink "MIT/GNU Scheme 文档" "https://www.gnu.org/software/mit-scheme/documentation/stable/mit-scheme-ref/Symbols.html") "，以及为了理解标准中的" (hyperlink "示例程序" "https://standards.scheme.org/corrected-r5rs/r5rs-Z-H-13.html#%_chap_Temp_9") "而学习了龙格-库塔法。顺便一说，龙格-库塔法看起来真挺不错的。")
        (paragraph "几个月前我也把" (hyperlink "IEEE Scheme 标准（IEEE 1178-1990）" "https://standards.ieee.org/ieee/1178/1787/") "读完过了。这个标准可以看作 Scheme R⁴RS 版本和 R⁵RS 版本之间的过渡形态，也是 SICP 第 2 版里经常提到的标准。当然，形式语义部分也看不懂。")
        (paragraph "最近还在看" (hyperlink "include-yy" "https://www.zhihu.com/people/aW5jZjE5") "的一篇文章" (hyperlink "《Scheme 的 call/cc》" "https://zhuanlan.zhihu.com/p/180473795") "。")
        (paragraph "计划下一步阅读现代 Scheme 标准，先后是" (hyperlink "R⁶RS" "https://r6rs.org/") "和" (hyperlink "R⁷RS" "https://r7rs.org/") "。其中" (hyperlink "R⁷RS-Large" "https://r7rs.org/large/") "的标准制定过程也一直在关注。开始关注" (hyperlink "RⁿRS" "https://scheme-reports.org/") "这一系列东西还是因为今年年中看到了" (hyperlink "閱卜錄" "https://www.zhihu.com/people/xiscei") "的一篇文章" (hyperlink "《Scheme 语言 R7RS-large 标准「程序」分卷草案发布》" "https://zhuanlan.zhihu.com/p/2040988210159940126") "。"))))
