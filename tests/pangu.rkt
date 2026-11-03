#lang racket

;; 盘古之白（pangu.rkt）的测试：只测“内联边界上是否补空格”。
;; 运行：raco test tests

(require rackunit
         "../tools/notation.rkt"
         "../tools/pangu.rkt")

(module+ test

  (define (pangu . xs) (pangu-inlines xs))

  (test-case "中文与拉丁互相靠拢时补空格"
    (check-equal? (pangu "中文" "abc") (list "中文" " " "abc"))
    (check-equal? (pangu "abc" "中文") (list "abc" " " "中文"))
    (check-equal? (pangu "共" "3" "人") (list "共" " " "3" " " "人")))

  (test-case "已有空白处不重复补"
    (check-equal? (pangu "中文 " "abc") (list "中文 " "abc"))
    (check-equal? (pangu "中文" " abc") (list "中文" " abc")))

  (test-case "标点视为中性，其两侧不补"
    (check-equal? (pangu "中文。" "abc") (list "中文。" "abc"))
    (check-equal? (pangu "中文" "（abc") (list "中文" "（abc")))

  (test-case "公式与句读之间补空格"
    (check-equal? (pangu ($ "x") "，然后") (list ($ "x") " " "，然后"))
    (check-equal? (pangu ($ "x") "。") (list ($ "x") " " "。")))

  (test-case "公式与中文补空格、与拉丁不补"
    (check-equal? (pangu "值为" ($ "x")) (list "值为" " " ($ "x")))
    (check-equal? (pangu ($ "x") "y") (list ($ "x") "y")))

  (test-case "纯空节点透明，含空白的节点隔断边界"
    (check-equal? (pangu "中文" "" "abc") (list "中文" "" " " "abc"))
    (check-equal? (pangu "中文" "  " "abc") (list "中文" "  " "abc")))

  (test-case "行内节点内部的边界也参与判断"
    ;; bold 的文字是 " abc"，自带前导空白，所以不再补
    (check-equal? (pangu "中文" (bold " abc")) (list "中文" (bold " abc")))
    ;; bold 的文字以字母开头且无空白，则补
    (check-equal? (pangu "中文" (bold "abc")) (list "中文" " " (bold "abc"))))

  (test-case "补充平面的汉字按中文处理"
    (define rare (string (integer->char #x20000)))
    (check-equal? (pangu rare "abc") (list rare " " "abc")))

  (test-case "幂等"
    (define xs (list "中文" ($ "x") "，abc"))
    (check-equal? (pangu-inlines (pangu-inlines xs)) (pangu-inlines xs))))
