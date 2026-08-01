#lang racket

(require "notation.rkt")

(provide pangu-inlines)

;; 盘古之白：在相邻内联元素的边界处，若一边是中文、另一边是字母或数字，
;; 且边界没有已有空白，则插入一个空格。只处理边界，不修改元素内部。
;; 句读符视为中性：不在它两侧插入空格。

(define (cjk? c)
  (define code (char->integer c))
  (or (and (>= code #x3400) (<= code #x4DBF))  ; CJK 扩展 A
      (and (>= code #x4E00) (<= code #x9FFF))  ; CJK 统一表意
      (and (>= code #x3040) (<= code #x30FF))  ; 平假名 / 片假名
      (and (>= code #xAC00) (<= code #xD7AF))  ; 谚文
      (and (>= code #xF900) (<= code #xFAFF)))) ; CJK 兼容表意

(define (latin-digit? c)
  (or (char<=? #\a c #\z)
      (char<=? #\A c #\Z)
      (char<=? #\0 c #\9)))

(define (char-kind c)
  (cond
    [(cjk? c) 'cjk]
    [(latin-digit? c) 'latin]
    [else 'other]))

(define (need-space? a b)
  (and a b
       (or (and (eq? (char-kind a) 'cjk) (eq? (char-kind b) 'latin))
           (and (eq? (char-kind a) 'latin) (eq? (char-kind b) 'cjk)))))

;; 返回 (values 首个非空白字符 末个非空白字符 是否以空白开头 是否以空白结尾)
(define (text-bounds x)
  (cond
    [(string? x) (string-bounds x)]
    [(node-bold? x) (children-bounds (node-bold-inlines x))]
    [(node-italic? x) (children-bounds (node-italic-inlines x))]
    [(node-strike? x) (children-bounds (node-strike-inlines x))]
    [(node-hyperlink? x) (inline-bounds (node-hyperlink-text x))]
    [(node-code-inline? x) (string-bounds (node-code-inline-code x))]
    [(node-inline-math? x) (string-bounds (node-inline-math-tex x))]
    [else (string-bounds "")]))

;; hyperlink 的文字可以是字符串、单个内联节点或内联列表
(define (inline-bounds v)
  (cond
    [(string? v) (string-bounds v)]
    [(list? v) (children-bounds v)]
    [else (text-bounds v)]))

(define (first-non-ws chars)
  (cond
    [(empty? chars) #f]
    [(char-whitespace? (car chars)) (first-non-ws (cdr chars))]
    [else (car chars)]))

(define (string-bounds s)
  (define chars (string->list s))
  (values (first-non-ws chars)
          (first-non-ws (reverse chars))
          (and (pair? chars) (char-whitespace? (car chars)))
          (and (pair? chars) (char-whitespace? (car (reverse chars))))))

(define (children-bounds xs)
  (cond
    [(empty? xs) (values #f #f #f #f)]
    [else
     (define-values (s1 _ignore ssp1 _ignore2) (text-bounds (car xs)))
     (define-values (_ignore3 en _ignore4 espn) (text-bounds (car (reverse xs))))
     (values s1 en ssp1 espn)]))

;; 在相邻元素边界处插入需要的 " " 文本节点
(define (pangu-inlines xs)
  (cond
    [(empty? xs) '()]
    [(empty? (cdr xs)) xs]
    [else
     (let loop ([prev (car xs)]
                [rest (cdr xs)]
                [acc '()])
       (define-values (_ignore pe _ignore2 pes) (text-bounds prev))
       (define-values (ns _ignore3 nss _ignore4) (text-bounds (car rest)))
       (define insert? (and (not pes) (not nss) (need-space? pe ns)))
       (define new-acc (if insert? (append acc (list prev " ")) (append acc (list prev))))
       (if (empty? (cdr rest))
           (append new-acc (list (car rest)))
           (loop (car rest) (cdr rest) new-acc)))]))
