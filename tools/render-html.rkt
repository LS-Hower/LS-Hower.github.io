#lang racket

(require "notation.rkt"
         "pangu.rkt"
         racket/list
         racket/string)

(provide
 (struct-out post-rec)
 (struct-out flat-page-rec)
 current-site-title
 current-author
 current-css-path
 current-favicon
 current-math-engine
 current-posts
 current-flat-pages
 current-output-name
 current-base
 render-document)

;; ---------- 站点页面记录 ----------

;; name: 基名（不含扩展名）；URL 在渲染时由 name + current-base 推导
(struct post-rec (name title publish-date update-date) #:transparent)
(struct flat-page-rec (name title) #:transparent)

;; ---------- 站点上下文参数（由 build.rkt 设置） ----------

(define current-site-title (make-parameter "小石"))
(define current-author (make-parameter ""))
(define current-css-path (make-parameter "main.css"))
(define current-favicon (make-parameter "favicon.ico"))
(define current-math-engine (make-parameter 'none)) ; 'none | 'katex | 'mathjax
(define current-posts (make-parameter '()))
(define current-flat-pages (make-parameter '()))
(define current-output-name (make-parameter ""))
(define current-base (make-parameter "")) ; "" 或 "../"（相对站点根）

;; ---------- 小工具 ----------

(define (post-url p) (string-append (current-base) "blog/" (post-rec-name p) ".html"))
(define (flat-page-url p) (string-append (current-base) "site/" (flat-page-rec-name p) ".html"))

(define (escape-text s)
  (string-append*
   (for/list ([c (in-string s)])
     (case c
       [(#\&) "&amp;"]
       [(#\<) "&lt;"]
       [(#\>) "&gt;"]
       [else (string c)]))))

(define (escape-attr s)
  (string-append*
   (for/list ([c (in-string s)])
     (case c
       [(#\&) "&amp;"]
       [(#\<) "&lt;"]
       [(#\>) "&gt;"]
       [(#\") "&quot;"]
       [(#\') "&#39;"]
       [else (string c)]))))

;; 普通文本：换行/连续空白折叠为单个空格（不 trim，保留作者控制的边界空格）
(define (collapse-ws s) (regexp-replace* #px"\\s+" s " "))

(define (pad2 n)
  (define s (number->string n))
  (if (< (string-length s) 2) (string-append "0" s) s))

(define (format-date d)
  (unless (node-date? d)
    (error "render-html: 期望 node-date，得到" d))
  (format "~a-~a-~a" (pad2 (node-date-year d)) (pad2 (node-date-month d)) (pad2 (node-date-day d))))

;; ---------- 内联渲染 ----------

(define (render-inline x)  (cond
    [(string? x) (escape-text (collapse-ws x))]
    [(node-code-inline? x)
     (format "<code>~a</code>" (escape-text (node-code-inline-code x)))]
    [(node-italic? x)
     (format "<em>~a</em>" (render-inlines (node-italic-inlines x)))]
    [(node-bold? x)
     (format "<strong>~a</strong>" (render-inlines (node-bold-inlines x)))]
    [(node-strike? x)
     (format "<del>~a</del>" (render-inlines (node-strike-inlines x)))]
    [(node-inline-math? x)
     (format "\\(~a\\)" (escape-text (node-inline-math-tex x)))]
    [(node-hyperlink? x)
     (define url (escape-attr (node-hyperlink-url x)))
     (define title (node-hyperlink-title x))
     (define text (render-inlines (list (node-hyperlink-text x))))
     (if title
         (format "<a href=\"~a\" title=\"~a\">~a</a>" url (escape-attr title) text)
         (format "<a href=\"~a\">~a</a>" url text))]
    [else (error "render-html: 未知的内联节点" x)]))

(define (render-inlines xs)
  (apply string-append (map render-inline (pangu-inlines xs))))

(define (inline-node? x)
  (or (string? x)
      (node-code-inline? x)
      (node-italic? x)
      (node-bold? x)
      (node-strike? x)
      (node-inline-math? x)
      (node-hyperlink? x)))

;; ---------- 自动节点 ----------

(define (render-posts-list count)
  (define posts (current-posts))
  (define shown (if (and (number? count) (< (length posts) count)) posts (take* posts count)))
  (string-append
   "<ul class=\"post-list\">\n"
   (apply string-append
          (for/list ([p (in-list shown)])
            (format "  <li><time>~a</time> <a href=\"~a\">~a</a></li>\n"
                    (format-date (post-rec-publish-date p))
                    (escape-attr (post-url p))
                    (escape-text (post-rec-title p)))))
   "</ul>\n"))

(define (take* xs n)
  (cond
    [(>= (length xs) n) (take xs n)]
    [else xs]))

(define (render-page-links)
  (string-append
   "<ul class=\"page-links\">\n"
   (apply string-append
          (for/list ([p (in-list (current-flat-pages))])
            (format "  <li><a href=\"~a\">~a</a></li>\n"
                    (escape-attr (flat-page-url p))
                    (escape-text (flat-page-rec-title p)))))
   "</ul>\n"))

;; ---------- 代码 / 表格 / 终端输出 ----------

;; code-block 内容：优先 #:from-file（相对站点根），否则用内联 code
(define (code-block-content b)
  (define from-file (node-code-block-from-file b))
  (cond
    [from-file (file->string (string->path from-file))]
    [(node-code-block-code b) (node-code-block-code b)]
    [else (error "render-html: code-block 既没有 code 也没有 #:from-file" b)]))

(define (row-cells r)
  (cond
    [(node-row? r) (node-row-cells r)]
    [(node-header-row? r) (node-header-row-cells r)]
    [else (error "render-html: 期望 row 或 header-row，得到" r)]))

(define (render-cell-lines lines)
  (string-join
   (for/list ([line (in-list lines)])
     (if (list? line) (render-inlines line) (render-inline line)))
   "<br>"))

(define (table-align align-list col)
  (if (and align-list (< col (length align-list)))
      (list-ref align-list col)
      'left))

(define (align-attr a)
  (case a
    [(left) "text-align:left"]
    [(center) "text-align:center"]
    [(right) "text-align:right"]
    [else (error "render-html: 未知的对齐" a)]))

;; 图片尺寸：数字解释为 em（相对文字高度），字符串按 CSS 原样
(define (css-length v)
  (if (number? v) (format "~aem" v) v))

(define (image-size-style b)
  (define parts
    (filter identity
            (list (and (node-image-width b)
                       (format "width:~a" (css-length (node-image-width b))))
                  (and (node-image-height b)
                       (format "height:~a" (css-length (node-image-height b)))))))
  (if (empty? parts) "" (format " style=\"~a\"" (string-join parts ";"))))

(define (render-table t)
  (define align-list (node-table-align t))
  (define headers (filter node-header-row? (node-table-rows t)))
  (define bodies (filter node-row? (node-table-rows t)))
  (define (render-row r header?)
    (define tag (if header? "th" "td"))
    (string-append
     "<tr>\n"
     (apply string-append
            (for/list ([c (in-list (row-cells r))] [col (in-naturals)])
              (format "  <~a style=\"~a\">~a</~a>\n"
                      tag
                      (align-attr (table-align align-list col))
                      (render-cell-lines (node-cell-lines c))
                      tag)))
     "</tr>\n"))
  (string-append
   "<table>\n"
   (if (empty? headers)
       ""
       (string-append "<thead>\n"
                      (apply string-append (map (lambda (r) (render-row r #t)) headers))
                      "</thead>\n"))
   (if (empty? bodies)
       ""
       (string-append "<tbody>\n"
                      (apply string-append (map (lambda (r) (render-row r #f)) bodies))
                      "</tbody>\n"))
   "</table>\n"))

;; ---------- 终端输出（ANSI SGR） ----------

(define ansi-fg
  (hash 30 "#000000" 31 "#cd3131" 32 "#00bc00" 33 "#949800"
        34 "#0451a5" 35 "#bc05bc" 36 "#0598bc" 37 "#555555"
        90 "#666666" 91 "#cd3131" 92 "#14ce14" 93 "#b5ba00"
        94 "#0451a5" 95 "#bc05bc" 96 "#0598bc" 97 "#a5a5a5"))

;; 解析一串 SGR 参数，返回新的前景色（#f = 无/重置）
(define (sgr-result code-str current)
  (define codes (filter (lambda (s) (not (equal? s "")))
                        (regexp-split #rx";" code-str)))
  (cond
    [(or (empty? codes) (member "0" codes)) #f]
    [else
     (or (for/first ([c (in-list codes)]
                     #:when (hash-has-key? ansi-fg (string->number c)))
           (hash-ref ansi-fg (string->number c)))
         current)]))

(define (ansi->html text)
  (define out (open-output-string))
  (define current #f)
  (define (set-style! new)
    (unless (equal? current new)
      (when current (write-string "</span>" out))
      (set! current new)
      (when current (write-string (format "<span style=\"color:~a\">" current) out))))
  (define len (string-length text))
  (let loop ([pos 0])
    (define m (regexp-match-positions #px"\x1b\\[([0-9;]*)m" text pos))
    (if m
        (let* ([whole (car m)] [codes (cadr m)])
          (write-string (escape-text (substring text pos (car whole))) out)
          (set-style! (sgr-result (substring text (car codes) (cdr codes)) current))
          (loop (cdr whole)))
        (begin
          (write-string (escape-text (substring text pos len)) out)
          (set-style! #f))))
  (get-output-string out))

;; 运行命令并捕获 stdout（UTF-8 解码），cwd 相对站点根
;; 强制 FORCE_COLOR=1，让支持颜色输出的程序（如 termcolor）在管道下也输出 ANSI
(define (run-terminal cmd cwd)
  (define dir (if cwd (build-path (current-directory) cwd) (current-directory)))
  (define saved-color (getenv "FORCE_COLOR"))
  (putenv "FORCE_COLOR" "1")
  (dynamic-wind
    (lambda () (void))
    (lambda ()
      (parameterize ([current-directory dir])
        (define handles (process cmd))
        (define stdout (list-ref handles 0))
        (define stdin (list-ref handles 1))
        (define stderr (list-ref handles 3))
        (close-output-port stdin)
        (define text (bytes->string/utf-8 (port->bytes stdout)))
        (close-input-port stdout)
        (when stderr (port->string stderr))
        text))
    (lambda () (when saved-color (putenv "FORCE_COLOR" saved-color)))))

;; ---------- 块渲染（含 section 自动编号） ----------

;; prefix :: (listof integer)，表示当前章节号前缀
(define (render-blocks blocks prefix numbered?)
  (define counter (box 0))
  (apply string-append
         (for/list ([b (in-list blocks)])
           (cond
             [(node-section? b)
              (set-box! counter (add1 (unbox counter)))
              (define number (append prefix (list (unbox counter))))
              (define level (min 6 (add1 (length number))))
              (define numstr (string-join (map number->string number) "."))
              (define id (format "sec-~a" (string-join (map number->string number) "-")))
              (define title
                (if numbered?
                    (format "~a ~a" numstr (escape-text (node-section-title b)))
                    (escape-text (node-section-title b))))
              (string-append
               (format "<h~a id=\"~a\">~a</h~a>\n" level id title level)
               (render-blocks (node-section-body b) number numbered?))]
             [(node-paragraph? b)
              (format "<p>~a</p>\n" (render-inlines (node-paragraph-inlines b)))]
             [(node-quote-block? b)
              (format "<blockquote>\n~a</blockquote>\n"
                      (render-blocks (node-quote-block-body b) prefix numbered?))]
             [(node-code-block? b)
              (define lang (node-code-block-lang b))
              (define class (if lang (format " class=\"language-~a\"" (escape-attr lang)) ""))
              (format "<pre><code~a>~a</code></pre>\n" class
                      (escape-text (code-block-content b)))]
             [(node-display-math? b)
              (format "<p class=\"math-display\">\\[~a\\]</p>\n"
                      (escape-text (node-display-math-tex b)))]
             [(node-horizontal-line? b) "<hr>\n"]
             [(node-table? b) (render-table b)]
             [(node-enumerate? b)
              (string-append
               "<ol>\n"
               (apply string-append
                      (for/list ([item (in-list (node-enumerate-items b))])
                        (format "  <li>~a</li>\n"
                                (if (list? item) (render-inlines item) (render-inline item)))))
               "</ol>\n")]
             [(node-terminal-output? b)
              (format "<pre class=\"terminal-output\">~a</pre>\n"
                      (ansi->html (run-terminal (node-terminal-output-run b)
                                                (node-terminal-output-cwd b))))]
             [(node-itemize? b)
              (string-append
               "<ul>\n"
               (apply string-append
                      (for/list ([item (in-list (node-itemize-items b))])
                        (format "  <li>~a</li>\n"
                                (if (list? item) (render-inlines item) (render-inline item)))))
               "</ul>\n")]
             [(node-image? b)
              (define img
                (format "<img src=\"~a\" alt=\"~a\"~a~a>"
                        (escape-attr (node-image-src b))
                        (escape-attr (node-image-alt b))
                        (if (node-image-title b)
                            (format " title=\"~a\"" (escape-attr (node-image-title b)))
                            "")
                        (image-size-style b)))
              (if (node-image-caption b)
                  (format "<figure>\n  ~a\n  <figcaption>~a</figcaption>\n</figure>\n"
                          img (escape-text (node-image-caption b)))
                  (format "<p>~a</p>\n" img))]
             [(node-posts-list? b) (render-posts-list (node-posts-list-count b))]
             [(node-page-links? b) (render-page-links)]
             [(inline-node? b) (format "<p>~a</p>\n" (render-inline b))]
             [else (error "render-html: 未知的块节点" b)]))))

;; ---------- 前后篇导航 ----------

(define (prev-next-nav)
  (define posts (current-posts))
  (define name (current-output-name))
  (if (empty? posts)
      ""
      (let ([idx (index-of (map post-rec-name posts) name)])
        (if idx
            (let ([newer (and (> idx 0) (list-ref posts (sub1 idx)))]
                  [older (and (< idx (sub1 (length posts))) (list-ref posts (add1 idx)))])
              (if (or newer older)
                  (string-append
                   "<nav class=\"post-nav\">"
                   (if newer
                       (format "<a class=\"prev\" href=\"~a\">‹ 上一篇：~a</a>"
                               (post-url newer) (escape-text (post-rec-title newer)))
                       "")
                   (if older
                       (format "<a class=\"next\" href=\"~a\">› 下一篇：~a</a>"
                               (post-url older) (escape-text (post-rec-title older)))
                       "")
                   "</nav>\n")
                  ""))
            ""))))

;; ---------- 数学 ----------

;; 扫描 AST，判断是否包含内联/展示数学节点
(define (contains-math? x)
  (cond
    [(node-inline-math? x) #t]
    [(node-display-math? x) #t]
    [(list? x) (ormap contains-math? x)]
    [(node-document? x) (contains-math? (node-document-body x))]
    [(node-section? x) (contains-math? (node-section-body x))]
    [(node-paragraph? x) (contains-math? (node-paragraph-inlines x))]
    [(node-quote-block? x) (contains-math? (node-quote-block-body x))]
    [(node-itemize? x) (contains-math? (node-itemize-items x))]
    [(node-bold? x) (contains-math? (node-bold-inlines x))]
    [(node-italic? x) (contains-math? (node-italic-inlines x))]
    [(node-strike? x) (contains-math? (node-strike-inlines x))]
    [else #f]))

(define (math-scripts engine)
  (case engine
    [(none) ""]
    [(katex)
     (string-append
      "    <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.css\">\n"
      "    <script defer src=\"https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.js\"></script>\n"
      "    <script defer src=\"https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/contrib/auto-render.min.js\"\n"
      "      onload=\"renderMathInElement(document.body, {delimiters:[{left:'\\\\(' , right:'\\\\)', display:false},{left:'\\\\[', right:'\\\\]', display:true}], throwOnError:false});\"></script>\n")]
    [(mathjax)
     (string-append
      "    <script>\n"
      "      window.MathJax = {tex: {inlineMath: [['\\\\(', '\\\\)']], displayMath: [['\\\\[', '\\\\]']]}};\n"
      "    </script>\n"
      "    <script defer src=\"https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-chtml.js\"></script>\n")]
    [else (error "render-html: 未知的数学引擎" engine)]))

;; ---------- 页面外壳 ----------

;; 页面顶部元信息块（发布/更新日期等）。字段可扩展，缺失的自动跳过。
(define (meta-block meta)
  (define fields
    (list
     (cons "发布日期"
           (and (node-metadata-publish-date meta)
                (format "<time pubdate>~a</time>"
                        (format-date (node-metadata-publish-date meta)))))
     (cons "更新日期"
           (and (node-metadata-update-date meta)
                (format "<time>~a</time>"
                        (format-date (node-metadata-update-date meta)))))))
  (define lines
    (for/list ([f (in-list fields)] #:when (cdr f))
      (format "  ~a：~a" (car f) (cdr f))))
  (if (empty? lines)
      ""
      (string-append "<div class=\"page-meta\">\n"
                     (string-join lines "\n")
                     "\n</div>\n")))

(define (render-document doc)
  (unless (node-document? doc)
    (error "render-html: 期望 document 节点，得到" doc))
  (define meta (node-document-metadata doc))
  (define title (node-metadata-title meta))
  (define base (current-base))
  (define body (node-document-body doc))
  (define body-html (render-blocks body '() (node-metadata-numbered meta)))
  (define home? (not (equal? (current-output-name) "index")))
  (define index-url (string-append base "index.html"))
  (define has-math? (contains-math? body))
  (define page-engine (node-metadata-math meta))
  (define eff-engine (if (eq? page-engine 'auto) (current-math-engine) page-engine))
  (when (and has-math? (eq? eff-engine 'none))
    (eprintf "WARNING: 页面“~a”使用了数学节点，但没有设置数学引擎（metadata #:math 或站级配置），公式将不会渲染。\n" title))
  (string-append
   "<!DOCTYPE html>\n\n"
   "<html lang=\"zh\">\n"
   "  <head>\n"
   (format "    <meta charset=\"UTF-8\">\n")
   (format "    <title>~a - ~a</title>\n" (escape-text title) (escape-text (current-site-title)))
   (format "    <link href=\"~a\" rel=\"stylesheet\" id=\"css\">\n"
           (escape-attr (string-append base (current-css-path))))
   (format "    <link rel=\"shortcut icon\" href=\"~a\">\n"
           (escape-attr (string-append base (current-favicon))))
   (if (and (current-author) (not (equal? (current-author) "")))
       (format "    <meta name=\"author\" content=\"~a\">\n" (escape-attr (current-author)))
       "")
   (if (and has-math? (not (eq? eff-engine 'none)))
       (math-scripts eff-engine)
       "")
   "  </head>\n\n"
   "  <body>\n"
   (format "    <header>\n      <h1>~a - ~a</h1>\n"
           (escape-text title) (escape-text (current-site-title)))
   (if home?
       (format "      <a class=\"home-button\" href=\"~a\">回到首页</a>\n" (escape-attr index-url))
       "")
   "    </header>\n"
   "    <hr>\n\n"
   "    <main>\n"
   ;; 元信息、上一篇/下一篇、正文三段，用 <hr> 分隔，空段跳过
   (string-join (filter (lambda (s) (not (equal? s "")))
                        (list (meta-block meta) (prev-next-nav) body-html))
                "\n<hr>\n\n")
   "    </main>\n"
   "  </body>\n"
   "</html>\n"))
