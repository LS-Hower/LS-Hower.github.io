#lang racket

;; 记号层（notation.rkt）的测试：内联序列的规范化与各构造函数的输入形态。
;; 运行：raco test tests

(require rackunit
         "../tools/notation.rkt")

(module+ test

  (test-case "内联位置接受单个内联"
    (check-equal? (node-paragraph-inlines (paragraph "a")) (list "a"))
    (check-equal? (node-bold-inlines (bold (code-inline "x"))) (list (code-inline "x")))
    (check-equal? (node-italic-inlines (italic "a")) (list "a")))

  (test-case "内联位置接受列表，并摊平嵌套列表"
    (check-equal? (node-paragraph-inlines (paragraph (list "a" (list "b")) "c"))
                  (list "a" "b" "c"))
    (check-equal? (node-bold-inlines (bold (list "a")))
                  (list "a")))

  (test-case "内联位置拒绝非内联"
    (check-exn exn:fail? (lambda () (paragraph (section "x"))))
    (check-exn exn:fail? (lambda () (paragraph 42))))

  (test-case "列表项统一成内联序列"
    (check-equal? (node-list-unordered-items (list-unordered "a" (list "b" "c")))
                  (list (list "a") (list "b" "c")))
    (check-equal? (node-list-ordered-items (list-ordered "x"))
                  (list (list "x"))))

  (test-case "cell 与 cell-multi-line"
    (check-equal? (node-cell-lines (cell "a")) (list (list "a")))
    (check-equal? (node-cell-lines (cell (list "a" (bold "b"))))
                  (list (list "a" (bold "b"))))
    (check-equal? (node-cell-lines (cell-multi-line (list "a" "b")))
                  (list (list "a") (list "b"))))

  (test-case "hyperlink 的文字统一成内联序列"
    (check-equal? (node-hyperlink-text (hyperlink "a" "u")) (list "a"))
    (check-equal? (node-hyperlink-text (hyperlink (list "a" (bold "b")) "u" #:title "t"))
                  (list "a" (bold "b")))
    (check-equal? (node-hyperlink-title (hyperlink "a" "u" #:title "t")) "t"))

  (test-case "公式节点"
    (check-equal? (node-inline-math-tex ($ "x")) "x")
    (check-equal? (node-display-math-tex ($$ "y")) "y"))

  (test-case "metadata 默认值"
    (define m (metadata #:title "t"))
    (check-equal? (node-metadata-title m) "t")
    (check-equal? (node-metadata-numbered m) #t)
    (check-equal? (node-metadata-math m) 'auto)
    (check-false (node-metadata-publish-date m))))
