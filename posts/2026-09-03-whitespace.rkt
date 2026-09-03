#lang racket

(require "../tools/notation.rkt")

(provide page)

(define page
  (document
    (metadata
      #:title "原来 Whitespace 语言甚至能用"
      #:publish-date (day-date 2026 9 3))
      (paragraph "几年前接触" (hyperlink "BF" "https://esolangs.org/wiki/Brainfuck") "这类神秘诡异抽象猎奇语言的时候，就已经听说了有" (hyperlink "Whitespace" "https://esolangs.org/wiki/Whitespace") "这门语言。不过我当时没认真学，只知道它源代码的有效部分只由空格、制表符和换行符构成。")
      (paragraph "昨晚突然就决定认真学习一下这门语言。结果还是非常 Amazing 的，这门语言学起来相当简单，而且这门语言甚至真的能用。主要还是得益于它内置了一点比较强的抽象功能，尤其是数据栈和堆，甚至还有调用和返回指令，配备着一个函数调用栈。虽然仍然极为简陋，但还是比只有字节纸带纯模仿图灵机的 BF 语言友好多了。")
      (paragraph "我为它设计了一门对应的汇编语言（一套助记符），之后或许会实现一个翻译器。")))
