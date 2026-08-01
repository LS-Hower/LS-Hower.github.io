#lang racket

(require "../tools/notation.rkt")

(provide page)

(define page
  (document
   (metadata
    #:title "带余除法策略"
    #:publish-date (day-date 2026 8 2)
    #:math 'katex)
   (section
    "引言"
    (paragraph
     "我上中学的时候，有同学问我 "
     ($ "-5")
     " 除以 "
     ($ "-2")
     " 得到的余数是几。好像 "
     ($ "1")
     " 和 "
     ($ "-1")
     " 作为答案都有道理。负数的带余除法这件事确实有点复杂。我将在这里总结一些带余除法策略。"))
   (section
    "记号"
    (paragraph
     "考虑一个带余除法的过程：")
    ($$ "z \\div n = q \\cdots r")
    (paragraph "我们称：")
    (itemize
     (list ($ "z") "为被除数；")
     (list ($ "n") "为除数；")
     (list ($ "q") "为商；")
     (list ($ "r") "为余数。")))
   (section
    "基本规则"
    (paragraph
     "除了 "
     ($ "n \\neq 0")
     " 这种众所周知的要求外，我们探讨的带余除法策略至少都要遵循如下三条规则。")
    (enumerate
     (list ($ "nq + r = z"))
     (list ($ "|r| < |n|"))
     (list ($ "q \\in \\mathbb{Z}[\\mathrm{i}]")))
    (paragraph
     ($ "\\mathbb{Z}[\\mathrm{i}]")
     " 是高斯整数集合。高斯整数是指满足了 "
     ($ "a \\in \\mathbb{Z}")
     " 和 "
     ($ "b \\in \\mathbb{Z}")
     " 的复数 "
     ($ "a + b \\mathrm{i}")
     " 。如果不考虑复数的话，把它换成 "
     ($ "\\mathbb{Z}")
     " 就够了。")
    (paragraph
     "在这里，等式 "
     ($ "nq + r = z")
     " 我们暂且称为“模除恒等式”。")
    (paragraph
     "给定任何一对 "
     ($ "(z, n)")
     " ，我们如果知道了 "
     ($ "q")
     " 和 "
     ($ "r")
     " 的其中一个，就自然能得到另一个，依据就是模除恒等式。所以我们可以通过只描述一个策略如何给出 "
     ($ "q")
     " 来完整地描述出这个策略，反之亦然。")
    (paragraph
     "给定任何一个带余除法策略，给定任何一对 "
     ($ "(z, n)")
     " ，策略所给出的符合规则的 "
     ($ "(q, r)")
     " ，也应当是有且仅有一对的。"))
   (section
    "各种带余除法策略"
    (section
     "基于将商取整的策略"
     (paragraph
      "严格地说，对于取整函数 "
      ($ "\\operatorname{round'}")
      " ，我们规定")
     ($$ "q = \\operatorname{round'} \\left( \\dfrac{z}{n} \\right)")
     (paragraph
      "然后再算出余数 "
      ($ "r")
      " 。")
     (paragraph
      "对于参数 "
      ($ "x")
      " ，取整函数必须满足 "
      ($ "x-1 < \\operatorname{round'}(x) < x+1")
      " 。直观上就是在说：对于整数取整，结果一定得是这个整数本身；对夹在两个相邻整数中间的值，结果一定得是这两个整数之中的一个。可以证明，这样的要求才能保证性质 "
      ($ "|r| < |n|")
      " 成立。（其实我没证明，我只是感觉它对。）")
     (paragraph "取整函数有很多种。列表如下：")
     (table
      (header-row (cell "中文名") (cell "英文名") (cell "所算出的余数拥有的性质"))
      (row (cell "向下取整") (cell "toward negative") (cell "与除数符号一致"))
      (row (cell "向上取整") (cell "toward positive") (cell "与除数符号相反"))
      (row (cell "趋零截断") (cell "toward zero") (cell "与被除数符号一致"))
      (row (cell "离零进位") (cell "toward away") (cell "与被除数符号相反"))
      (row (cell "约半向下（四舍五入）") (cell "ties to negative") (cell "绝对值不超过除数绝对值一半"))
      (row (cell "约半向上（五舍六入）") (cell "ties to positive") (cell "绝对值不超过除数绝对值一半"))
      (row (cell "约半趋零") (cell "ties to zero") (cell "绝对值不超过除数绝对值一半"))
      (row (cell "约半离零") (cell "ties to away") (cell "绝对值不超过除数绝对值一半"))
      (row (cell "约半成偶（奇进偶舍）") (cell "ties to even") (cell "绝对值不超过除数绝对值一半"))
      (row (cell "约半成奇（偶进奇舍）") (cell "ties to odd") (cell "绝对值不超过除数绝对值一半")))
     (paragraph
      "这里的英文起名方法参考了"
      (hyperlink
       "IEEE 754-2019"
       "https://standards.ieee.org/ieee/754/6210/")
      "标准。")
     (paragraph "我们之后就可以用取整方式来称呼其所对应的带余除法策略了。")
     (paragraph
      "似乎 ties to even 和 ties to odd 没有对应的 toward even 和 toward odd。然而后两者的设计其实已经和“如何将实数修约为整数”这个问题本身一样难缠了。至少部分是这样。"))
    (section
     "基于无条件控制余数符号的策略"
     (paragraph
      "限制余数只能在某个长度为 "
      ($ "|n|")
      " 而非 "
      ($ "|2n|")
      " 且半闭半开的范围内，这样便唯一确定了余数 "
      ($ "r")
      " ，从而确定了商 "
      ($ "q")
      " 。")
     (paragraph "严格地说，所有可能的余数只能在如下集合中：")
     ($$ "\\{\\ldots, \\, z - 2|n|, \\, z - |n|, \\, z, \\, z + |n|, \\, z + 2|n|, \\ldots\\}")
     (paragraph
      "我们规定某个形如 "
      ($ "[b, b + |n|)")
      " 或形如 "
      ($ "(b - |n|, b]")
      " 的区间，则上述集合与这一区间的交集必定有且仅有一个数，它就是 "
      ($ "r")
      " 。随后再据此算出 "
      ($ "q")
      " 。")
     (paragraph
      "当然，区间必须包含于 "
      ($ "(-|n|, |n|)")
      " 中，以满足 "
      ($ "|r| < |n|")
      " 这一基本规则。")
     (paragraph "有四种区间，它们便能对应四种带余除法策略。")
     (itemize
      (list ($ "r \\in [0, |n|)") "（也叫欧几里得带余除法）")
      (list ($ "r \\in (-|n|, 0]"))
      (list ($ "r \\in \\left[ -\\dfrac{|n|}{2}, \\dfrac{|n|}{2} \\right)"))
      (list ($ "r \\in \\left( -\\dfrac{|n|}{2}, \\dfrac{|n|}{2} \\right]")))
     (paragraph
      "例如用欧几里得除法计算 "
      ($ "-19 \\div -3")
      " 。随便找一个带余除法策略（比如向下取整策略）得到一个备选余数为 "
      ($ "-1")
      " 。于是另一个备选就将是 "
      ($ "-1 + \\left| -3 \\right| = 2")
      " 。所以余数 "
      ($ "r")
      " 的两个可能备选项分别是 "
      ($ "-1")
      " 和 "
      ($ "2")
      " 。我们要选非负，也就是满足所谓的 "
      ($ "r \\in [0, |n|)")
      " 的。所以 "
      ($ "r = 2")
      " 。"))
    (section
     "基于先将被除数和/或除数取绝对值再做其他除法的策略"
     (paragraph
      "欧几里得带余除法还可以看作：对除数先取绝对值再做某个其他除法得到商再为之添加与除数相同的符号。这里的“某个其他除法”是向下取整除法。对偶地，若改为向上取整除法，那么就是“余数恒为非正”了。")
     (paragraph "因此可以推广：")
     (itemize
      (list "对除数先取绝对值再做上方两大类的除法")
      (list "对被除数先取绝对值再做上方两大类的除法")
      (list "同时先对被除数和除数都取一下绝对值再做上方两大类的除法"))
     (paragraph
      "例如，对除数先取绝对值再做向下取整除法再为商添加与除数相同的符号，严格描述即为：")
     ($$ "q = \\operatorname{sgn}(n) \\left\\lfloor \\dfrac{z}{|n|} \\right\\rfloor")
     (paragraph "我们将这样的带余除法策略记作“向下取整_n”。相应地还可以有“向下取整_z”：")
     ($$ "q = \\operatorname{sgn}(z) \\left\\lfloor \\dfrac{|z|}{n} \\right\\rfloor")
     (paragraph "以及“向下取整_zn”：")
     ($$ "q = \\operatorname{sgn}(z) \\operatorname{sgn}(n) \\left\\lfloor \\dfrac{|z|}{|n|} \\right\\rfloor")
     (paragraph
      "先前的所有带余除法策略都可以这样衍生出三个新版本，策略数量立刻便翻了四倍。")
     (paragraph
      "不过其实很多策略是本质相同的。例如正如本节开头所说，刚刚的“向下取整_n”其实和“余数非负”策略完全相同。稍后会用代码分析被除数和除数在各种条件下，策略的行为等价类。")
     (paragraph "事实上，这些策略中只有四种是新的：")
     (table
      (header-row (cell "策略") (cell "所算出的余数拥有的性质"))
      (row (cell "向下取整_z") (cell "与被除数和除数符号的异或一致"))
      (row (cell "向上取整_z") (cell "与被除数和除数符号的同或一致"))
      (row (cell "约半向下_z") (cell "绝对值不超过除数绝对值一半"))
      (row (cell "约半向上_z") (cell "绝对值不超过除数绝对值一半")))
     (paragraph
      "这里有了“异或”“同或”。我们是将负号看成 1（true）、正号看成 0（false）来计算的。")))
   (section
    "图表"
    (paragraph
     "每一个子图，所使用的带余除法策略和除数 "
     ($ "n")
     " 都是固定的。横轴为被除数 "
     ($ "z")
     " ，红色点是商 "
     ($ "q")
     " ，绿色点是余数 "
     ($ "r")
     " 。这一设定模仿了维基百科页面 "
     (hyperlink "模除" "https://zh.wikipedia.org/wiki/%E6%A8%A1%E9%99%A4")
     " 。")
    (image "../assets/divmod_plots.png" #:alt "无后缀的" #:caption "无后缀的" #:width 42)
    (image "../assets/divmod_plots_z.png" #:alt "以 _z 为后缀的" #:caption "以 _z 为后缀的" #:width 42)
    (image "../assets/divmod_plots_n.png" #:alt "以 _n 为后缀的" #:caption "以 _n 为后缀的" #:width 42)
    (image "../assets/divmod_plots_zn.png" #:alt "以 _zn 为后缀的" #:caption "以 _zn 为后缀的" #:width 42)
    (paragraph "画图代码见文末。"))
   (section
    "各种带余除法策略之间的比较"
    (paragraph "我们可以从如下几个方面比较各种带余除法策略。")
    (itemize
     (list "周期：在除数确定时，余数是被除数的周期函数；")
     (list "单调：在满足上一条的前提下，能在周期上单调；")
     (list "被同：在被除数符号确定时，存在一个方向使得余数所在区间总是这边闭那边开；")
     (list "除同：在除数符号确定时，存在一个方向使得余数所在区间总是这边闭那边开；")
     (list "小学：与小学数学（被除数和除数都为正……）兼容；")
     (list "数论：与数论（除数为正……）兼容；")
     (list "复数：可推广至复数；")
     (list "近零：满足 " ($ "r \\in \\left[ -\\dfrac{|n|}{2}, \\dfrac{|n|}{2} \\right]")))
    (paragraph "表格如下：")
    (table
     #:align '(left center center center center center center center center)
     (header-row (cell "策略") (cell "周期") (cell "单调") (cell "被同") (cell "除同") (cell "小学") (cell "数论") (cell "复数") (cell "近零"))
     (row (cell "向下取整") (cell "✔") (cell "✔") (cell "") (cell "✔") (cell "✔") (cell "✔") (cell "✔") (cell ""))
     (row (cell "向上取整") (cell "✔") (cell "✔") (cell "") (cell "✔") (cell "") (cell "") (cell "✔") (cell ""))
     (row (cell "趋零截断") (cell "") (cell "") (cell "✔") (cell "") (cell "✔") (cell "") (cell "✔") (cell ""))
     (row (cell "离零进位") (cell "") (cell "") (cell "✔") (cell "") (cell "") (cell "") (cell "✔") (cell ""))
     (row (cell "约半向下") (cell "✔") (cell "✔") (cell "") (cell "✔") (cell "") (cell "") (cell "✔") (cell "✔"))
     (row (cell "约半向上") (cell "✔") (cell "✔") (cell "") (cell "✔") (cell "") (cell "") (cell "✔") (cell "✔"))
     (row (cell "约半趋零") (cell "") (cell "") (cell "✔") (cell "") (cell "") (cell "") (cell "✔") (cell "✔"))
     (row (cell "约半离零") (cell "") (cell "") (cell "✔") (cell "") (cell "") (cell "") (cell "✔") (cell "✔"))
     (row (cell "约半成偶") (cell "✔") (cell "") (cell "") (cell "") (cell "") (cell "") (cell "✔") (cell "✔"))
     (row (cell "约半成奇") (cell "✔") (cell "") (cell "") (cell "") (cell "") (cell "") (cell "✔") (cell "✔"))
     (row (cell "余数非负") (cell "✔") (cell "✔") (cell "✔") (cell "✔") (cell "✔") (cell "✔") (cell "") (cell ""))
     (row (cell "余数非正") (cell "✔") (cell "✔") (cell "✔") (cell "✔") (cell "") (cell "") (cell "") (cell ""))
     (row (cell "约半左闭") (cell "✔") (cell "✔") (cell "✔") (cell "✔") (cell "") (cell "") (cell "") (cell "✔"))
     (row (cell "约半右闭") (cell "✔") (cell "✔") (cell "✔") (cell "✔") (cell "") (cell "") (cell "") (cell "✔"))
     (row (cell "向下取整_z") (cell "") (cell "") (cell "") (cell "") (cell "✔") (cell "") (cell "") (cell ""))
     (row (cell "向上取整_z") (cell "") (cell "") (cell "") (cell "") (cell "") (cell "") (cell "") (cell ""))
     (row (cell "约半向下_z") (cell "") (cell "") (cell "") (cell "") (cell "") (cell "") (cell "") (cell "✔"))
     (row (cell "约半向上_z") (cell "") (cell "") (cell "") (cell "") (cell "") (cell "") (cell "") (cell "✔")))
    (paragraph
     "没有评价“硬件支持是否容易”这个指标，因为我不懂硬件。")
    (paragraph
     "这个表格主要评测的是余数的性质好不好，所以对约半成偶和约半成奇有些不公平。而在实际中，这两种修约方式，以及对应的带余除法，其实是相当推荐的。"
     (hyperlink
      "IEEE 754"
      "https://standards.ieee.org/ieee/754/6210/")
     "标准中要求实现提供的“remainder”操作更是要求无视其他设置，总是使用约半成偶的除法。"))
   (section
    "行为的等价类"
    (paragraph
     "许多除法在不同情况下行为是可能相同的，我们可以划分等价类。")
    (terminal-output #:run "python -X utf8 divmod_plots.py" #:cwd "assets")
    (paragraph "生成代码见文末。"))
   (section
    "在一些编程语言中的情况"
    (paragraph
     (bold "TODO: 排版目前有问题。"))
    #;
    (table
     #:align '(center center center center)
     (header-row (cell "语言") (cell "向下取整") (cell "趋零截断") (cell "约半成偶"))
     (row (cell "C++")
          (cell "")
          (cell-multi-line
           (list (list (code-inline "/") (code-inline "%") " (C++11 起),")
                 (list (code-inline ",l,ll,imax") (code-inline "div"))
                 (list (code-inline "fmod") (code-inline ",f,l"))))
          (cell-multi-line
           (list (list (code-inline "remainder") (code-inline ",f,l"))
                 (list (code-inline "remquo") (code-inline ",f,l")))))
     (row (cell "Python")
          (cell (list "(" (code-inline "//") ", " (code-inline "%") "), " (code-inline "divmod")))
          (cell (list (code-inline "math.fmod")))
          (cell (list (code-inline "math.remainder"))))
     (row (cell "C#, F#")
          (cell "")
          (cell (list "(" (code-inline "/") ", " (code-inline "%") "), " (code-inline "Math.DivRem")))
          (cell (list (code-inline "Math") "{" (code-inline ",F") "}.IEEERemainder")))
     (row (cell "Scheme R5RS")
          (cell (list (code-inline "modulo")))
          (cell (list "(" (code-inline "quotient") ", " (code-inline "remainder") ")"))
          (cell ""))
     (row (cell "Scheme R6RS")
          (cell (list (code-inline "modulo")))
          (cell (list "(" (code-inline "quotient") ", " (code-inline "remainder") ")"))
          (cell ""))
     (row (cell "Racket")
          (cell (list (code-inline "modulo")))
          (cell-multi-line
           (list (list "(" (code-inline "quotient") ", " (code-inline "remainder") "),")
                 (list (code-inline "quotient/remainder"))))
          (cell ""))
     (row (cell "Common Lisp")
          (cell (list "{" (code-inline ",f") "}" (code-inline "floor") ", " (code-inline "mod")))
          (cell (list "{" (code-inline ",f") "}" (code-inline "truncate") ", " (code-inline "rem")))
          (cell (list "{" (code-inline ",f") "}" (code-inline "round"))))
     (row (cell "Haskell")
          (cell-multi-line
           (list (list "(" (code-inline "div") ", " (code-inline "mod") "){...},")
                 (list (code-inline "divMod") "{...},")
                 (list (code-inline "Data.Fixed.") "{" (code-inline "div'") ", " (code-inline "mod'") "), " (code-inline "divMod'") "}")))
          (cell-multi-line
           (list (list "(" (code-inline "quot") ", " (code-inline "rem") "){...},")
                 (list (code-inline "quotRem") "{...}")))
          (cell "")))
    #;
    (table
     #:align '(center center center center center)
     (header-row (cell "语言") (cell "向上取整") (cell "余数非负") (cell "约半左闭") (cell "有理除法"))
     (row (cell "C++") (cell "") (cell "") (cell "") (cell ""))
     (row (cell "Python") (cell "") (cell "") (cell "") (cell (list (code-inline "fractions.Fraction"))))
     (row (cell "C#, F#") (cell "") (cell "") (cell "") (cell ""))
     (row (cell "Scheme R5RS") (cell "") (cell "") (cell "") (cell (list (code-inline "/"))))
     (row (cell "Scheme R6RS")
          (cell "")
          (cell-multi-line
           (list (list "{" (code-inline ",fl,fx") "}(" (code-inline "div") ", " (code-inline "mod") "),")
                 (list "{" (code-inline ",fl,fx") "}" (code-inline "div-and-mod"))))
          (cell-multi-line
           (list (list "{" (code-inline ",fl,fx") "}(" (code-inline "div0") ", " (code-inline "mod0") "),")
                 (list "{" (code-inline ",fl,fx") "}" (code-inline "div0-and-mod0"))))
          (cell (list (code-inline "/"))))
     (row (cell "Racket")
          (cell "")
          (cell-multi-line
           (list (list "{" (code-inline ",fl,fx") "}(" (code-inline "div") ", " (code-inline "mod") "),")
                 (list "{" (code-inline ",fl,fx") "}" (code-inline "div-and-mod"))))
          (cell-multi-line
           (list (list "{" (code-inline ",fl,fx") "}(" (code-inline "div0") ", " (code-inline "mod0") "),")
                 (list "{" (code-inline ",fl,fx") "}" (code-inline "div0-and-mod0"))))
          (cell (list (code-inline "/"))))
     (row (cell "Common Lisp")
          (cell (list "{" (code-inline ",f") "}" (code-inline "ceiling")))
          (cell "") (cell "") (cell (list (code-inline "/"))))
     (row (cell "Haskell")
          (cell "") (cell "") (cell "") (cell (list (code-inline "Data.Ratio") "." (code-inline "%")))))
    (paragraph
     "关于 C++ 的 "
     (code-inline "/")
     " 和 "
     (code-inline "%")
     " 行为的变更，见 "
     (hyperlink "CWG issue 614" "https://cplusplus.github.io/CWG/issues/614.html")
     " 。")
    (paragraph
     "关于在更多语言中的情况，参考维基百科页面 "
     (hyperlink "模除" "https://zh.wikipedia.org/wiki/%E6%A8%A1%E9%99%A4")
     " 。"))
   (section
    "代码"
    (paragraph "这里是生成图与等价类输出的完整代码。")
    (code-block #:lang "python" #:from-file "assets/divmod_plots.py"))))
