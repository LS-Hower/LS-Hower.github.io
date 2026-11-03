#lang racket

(require "notation.rkt"
         racket/list)

(provide pangu-inlines)

;; 盘古之白：在相邻内联的边界处，若一边是中文、另一边是字母或数字，
;; 且边界没有已有空白，则插入一个空格。只处理边界，不修改元素内部。
;; 句读符视为中性：不在它两侧插入空格。

;; ---------- 字符分类 ----------

(define (code-in? c lo hi) (<= lo (char->integer c) hi))

;; 中文判定。补充平面的生僻字也覆盖在内，以免它们被当成“其他”而吃掉空格。
(define (cjk? c)
  (or (code-in? c #x2E80 #x2EFF)     ; 部首补充
      (code-in? c #x3040 #x30FF)     ; 平假名 / 片假名
      (code-in? c #x31C0 #x31EF)     ; 笔画
      (code-in? c #x3400 #x4DBF)     ; 统一表意扩展 A
      (code-in? c #x4E00 #x9FFF)     ; 统一表意
      (code-in? c #xAC00 #xD7AF)     ; 谚文音节
      (code-in? c #xF900 #xFAFF)     ; 兼容表意
      (code-in? c #x20000 #x2FA1F))) ; 统一表意扩展 B 及以后

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
  (or (and (eq? (char-kind a) 'cjk) (eq? (char-kind b) 'latin))
      (and (eq? (char-kind a) 'latin) (eq? (char-kind b) 'cjk))))

;; ---------- 取内联的首末字符 ----------

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

;; 行内公式整体当作一个“拉丁词”看待：它与中文之间的空格，
;; 不该随着 TeX 源码首末字符是字母还是 \{、\}、\ 而变化。
(define (formula-bounds) (values #\A #\A #f #f))

;; 返回 (values 首字符 末字符 是否以空白开头 是否以空白结尾)。
;; 没有可见字符时首末字符为 #f；此时空白标记表示“是否含空白”，
;; 用来区分“纯空节点”（透明）与“空白节点”（隔断边界）。
(define (text-bounds x)
  (cond
    [(string? x) (string-bounds x)]
    [(node-bold? x) (children-bounds (node-bold-inlines x))]
    [(node-italic? x) (children-bounds (node-italic-inlines x))]
    [(node-strike? x) (children-bounds (node-strike-inlines x))]
    [(node-hyperlink? x) (seq-bounds (node-hyperlink-text x))]
    [(node-code-inline? x) (string-bounds (node-code-inline-code x))]
    [(node-inline-math? x) (formula-bounds)]
    [else (string-bounds "")]))

(define (seq-bounds v)
  (if (list? v) (children-bounds v) (text-bounds v)))

;; 首个/末个有可见字符的孩子，返回 (cons 字符 空白标记) 或 #f；
;; 纯空节点被跳过，边界判断因而可以穿透它们
(define (first-visible xs)
  (cond
    [(empty? xs) #f]
    [else
     (define-values (f _last lead-ws _trail) (text-bounds (car xs)))
     (if f (cons f lead-ws) (first-visible (cdr xs)))]))

(define (last-visible xs)
  (cond
    [(empty? xs) #f]
    [else
     (define-values (_first l _lead trail-ws) (text-bounds (car (reverse xs))))
     (if l (cons l trail-ws) (last-visible (drop-right xs 1)))]))

(define (children-bounds xs)
  (define head (first-visible xs))
  (define tail (last-visible xs))
  (values (and head (car head))
          (and tail (car tail))
          (and head (cdr head))
          (and tail (cdr tail))))

;; ---------- 组装 ----------

;; 全角句读符：公式与它们相邻时，按本站的排版偏好仍留一个空格。
;; 例：“\(z\) ，红色点是商”而不是“\(z\)，红色点是商”。
(define (pause-char? c)
  (and c (memv c (string->list "，。、；：！？"))))

;; 上一次出现的可见内联：节点本身（用来判断是不是公式）+ 末字符 + 尾部是否空白
(struct prev-info (node last-char trail-ws?) #:transparent)

(define (insert-space? prev first-char lead-ws)
  (and prev
       (not (prev-info-trail-ws? prev))
       (not lead-ws)
       (or (need-space? (prev-info-last-char prev) first-char)
           (and (node-inline-math? (prev-info-node prev))
                (pause-char? first-char)))))

(define (pangu-inlines xs)
  (define (step x prev acc)
    (define-values (first-char last-char lead-ws trail-ws) (text-bounds x))
    (cond
      [(not first-char)
       ;; 零宽节点：纯空节点透明（不打断 prev），含空白的节点隔断边界
       (values (if (or lead-ws trail-ws) #f prev)
               (cons x acc))]
      [else
       (define insert? (insert-space? prev first-char lead-ws))
       (values (prev-info x last-char trail-ws)
               (if insert? (list* x " " acc) (cons x acc)))]))
  (define-values (_ rev)
    (for/fold ([prev #f] [acc '()]) ([x (in-list xs)])
      (step x prev acc)))
  (reverse rev))
