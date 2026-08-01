#lang racket

(require "../tools/notation.rkt")

(provide page)

(define page
  (document
   (metadata
    #:title "示例页面"
    #:publish-date (day-date 2026 8 1)
    #:update-date (day-date 2026 8 2))
   (section
    "小标题"
    (paragraph
     "这是第一行。")
    (paragraph
     "这是第二行。")
    (paragraph
     "这是第三行。这一行里有一个"
     (hyperlink
      "超链接"
      "https://example.com/")
     "，它指向"
     (code-inline "example.com")
     "。")
    (paragraph
     (bold "这是第四行。还被加粗了。"))
    (section
     "又一个小标题，注意这是嵌套的"
     (paragraph
      "在其他文档语言里，这个东西要用 subsection 表示了。但我们这个 section 包含在更大的 section 里，自然地表示了嵌套关系。")))))
