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

;; 图片尺寸：数字解释为 em（相对文字高度），字符串按 CSS 原样
(define (css-length v)
  (if (number? v) (format "~aem" v) v))

;; ---------- 缩进 ----------

;; 一行“行”指不含换行的文本；块渲染器统一产出 (listof string)，
;; 由 at 统一加上缩进，最后 join-lines 拼成最终文本。
;; 唯一例外是 <pre> 里的代码：其内部换行属于内容，不再被缩进。

(define indent-unit "  ")

(define (indent level)
  (cond
    [(zero? level) ""]
    [else (string-append indent-unit (indent (sub1 level)))]))

;; 给若干行套上某一层的缩进；空行保持为空行（不留行尾空白）
(define (at level lines)
  (cond
    [(zero? level) lines]
    [else
     (for/list ([line (in-list lines)])
       (if (string=? line "") "" (string-append (indent level) line)))]))

(define (join-lines lines)
  (string-append* (for/list ([line (in-list lines)]) (string-append line "\n"))))

;; ---------- 内联渲染 ----------

(define (render-inline x)
  (cond
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
     (define text (render-inlines (node-hyperlink-text x)))
     (if title
         (format "<a href=\"~a\" title=\"~a\">~a</a>" url (escape-attr title) text)
         (format "<a href=\"~a\">~a</a>" url text))]
    [else (error "render-html: 未知的内联节点" x)]))

;; xs 是内联序列（list），由 notation.rkt 保证
(define (render-inlines xs)
  (string-append* (map render-inline (pangu-inlines xs))))

(define (inline-node? x)
  (or (string? x)
      (node-code-inline? x)
      (node-italic? x)
      (node-bold? x)
      (node-strike? x)
      (node-inline-math? x)
      (node-hyperlink? x)))

;; ---------- 自动节点 ----------

(define (take-up-to xs n)
  (cond
    [(not (number? n)) xs]
    [(>= (length xs) n) (take xs n)]
    [else xs]))

(define (posts-list-lines count level)
  (define shown (take-up-to (current-posts) count))
  (append
   (at level (list "<ul class=\"post-list\">"))
   (at (add1 level)
       (for/list ([p (in-list shown)])
         (format "<li><time>~a</time> <a href=\"~a\">~a</a></li>"
                 (format-date (post-rec-publish-date p))
                 (escape-attr (post-url p))
                 (escape-text (post-rec-title p)))))
   (at level (list "</ul>"))))

(define (page-links-lines level)
  (append
   (at level (list "<ul class=\"page-links\">"))
   (at (add1 level)
       (for/list ([p (in-list (current-flat-pages))])
         (format "<li><a href=\"~a\">~a</a></li>"
                 (escape-attr (flat-page-url p))
                 (escape-text (flat-page-rec-title p)))))
   (at level (list "</ul>"))))

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

;; cell 的 lines 是内联序列的列表，行与行之间用 <br> 连接
(define (render-cell c)
  (string-join
   (for/list ([line (in-list (node-cell-lines c))])
     (render-inlines line))
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

(define (image-size-style b)
  (define parts
    (filter identity
            (list (and (node-image-width b)
                       (format "width:~a" (css-length (node-image-width b))))
                  (and (node-image-height b)
                       (format "height:~a" (css-length (node-image-height b)))))))
  (if (empty? parts) "" (format " style=\"~a\"" (string-join parts ";"))))

(define (table-lines t level)
  (define align-list (node-table-align t))
  (define header-rows (filter node-header-row? (node-table-rows t)))
  (define body-rows (filter node-row? (node-table-rows t)))
  (define (row-lines r header? row-level)
    (define tag (if header? "th" "td"))
    (append
     (at row-level (list "<tr>"))
     (at (add1 row-level)
         (for/list ([c (in-list (row-cells r))] [col (in-naturals)])
           (format "<~a style=\"~a\">~a</~a>"
                   tag
                   (align-attr (table-align align-list col))
                   (render-cell c)
                   tag)))
     (at row-level (list "</tr>"))))
  (append
   (at level (list "<table>"))
   (if (empty? header-rows)
       '()
       (append (at (add1 level) (list "<thead>"))
               (append* (for/list ([r (in-list header-rows)]) (row-lines r #t (+ level 2))))
               (at (add1 level) (list "</thead>"))))
   (if (empty? body-rows)
       '()
       (append (at (add1 level) (list "<tbody>"))
               (append* (for/list ([r (in-list body-rows)]) (row-lines r #f (+ level 2))))
               (at (add1 level) (list "</tbody>"))))
   (at level (list "</table>"))))

;; ---------- 块渲染（含 section 自动编号） ----------

;; 返回行列表；prefix 是当前章节号前缀（(listof integer)）
(define (blocks-lines blocks prefix numbered? level)
  (define counter (box 0))
  (append*
   (for/list ([b (in-list blocks)])
     (block-lines b counter prefix numbered? level))))

(define (block-lines b counter prefix numbered? level)
  (cond
    [(node-section? b)
     (set-box! counter (add1 (unbox counter)))
     (define number (append prefix (list (unbox counter))))
     (define hlevel (min 6 (add1 (length number))))
     (define numstr (string-join (map number->string number) "."))
     (define anchor (format "sec-~a" (string-join (map number->string number) "-")))
     (define heading (escape-text (node-section-title b)))
     (define text (if numbered? (format "~a ~a" numstr heading) heading))
     (append
      (at level (list (format "<h~a id=\"~a\">~a</h~a>" hlevel anchor text hlevel)))
      (blocks-lines (node-section-body b) number numbered? level))]

    [(node-paragraph? b)
     (at level (list (format "<p>~a</p>" (render-inlines (node-paragraph-inlines b)))))]

    [(node-quote-block? b)
     (append
      (at level (list "<blockquote>"))
      (blocks-lines (node-quote-block-body b) prefix numbered? (add1 level))
      (at level (list "</blockquote>")))]

    [(node-code-block? b)
     (define lang (node-code-block-lang b))
     (define class (if lang (format " class=\"language-~a\"" (escape-attr lang)) ""))
     ;; 代码内部的换行是内容，只有起始行跟随缩进
     (at level (list (format "<pre><code~a>~a</code></pre>"
                             class
                             (escape-text (code-block-content b)))))]

    [(node-display-math? b)
     (at level (list (format "<p class=\"math-display\">\\[~a\\]</p>"
                             (escape-text (node-display-math-tex b)))))]

    [(node-horizontal-line? b)
     (at level (list "<hr>"))]

    [(node-table? b)
     (table-lines b level)]

    [(or (node-list-unordered? b) (node-list-ordered? b))
     (define ordered? (node-list-ordered? b))
     (define tag (if ordered? "ol" "ul"))
     (define items (if ordered? (node-list-ordered-items b) (node-list-unordered-items b)))
     (append
      (at level (list (format "<~a>" tag)))
      (at (add1 level)
          (for/list ([item (in-list items)])
            (format "<li>~a</li>" (render-inlines item))))
      (at level (list (format "</~a>" tag))))]

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
         (append
          (at level (list "<figure>"))
          (at (add1 level) (list img (format "<figcaption>~a</figcaption>"
                                             (escape-text (node-image-caption b)))))
          (at level (list "</figure>")))
         (at level (list (format "<p>~a</p>" img))))]

    [(node-posts-list? b)
     (posts-list-lines (node-posts-list-count b) level)]

    [(node-page-links? b)
     (page-links-lines level)]

    [(inline-node? b)
     (at level (list (format "<p>~a</p>" (render-inline b))))]

    [else (error "render-html: 未知的块节点" b)]))

;; ---------- 前后篇导航 ----------

;; 无相邻文章时也占一行（“无”），以免顶部高度变化
(define (prev-link p)
  (if p
      (format "<a class=\"prev\" href=\"~a\">‹ 更晚的一篇：~a</a>"
              (post-url p) (escape-text (post-rec-title p)))
      "<span class=\"prev\">‹ 更晚的一篇：无</span>"))

(define (next-link p)
  (if p
      (format "<a class=\"next\" href=\"~a\">› 更早的一篇：~a</a>"
              (post-url p) (escape-text (post-rec-title p)))
      "<span class=\"next\">› 更早的一篇：无</span>"))

(define (post-nav-lines level)
  (define posts (current-posts))
  (define idx (and (pair? posts)
                   (index-of (map post-rec-name posts) (current-output-name))))
  (cond
    [(not idx) '()]
    [else
     (define newer (and (> idx 0) (list-ref posts (sub1 idx))))
     (define older (and (< idx (sub1 (length posts))) (list-ref posts (add1 idx))))
     (append
      (at level (list "<nav class=\"post-nav\">"))
      (at (add1 level) (list (prev-link newer) (next-link older)))
      (at level (list "</nav>")))]))

;; ---------- 数学 ----------

;; 扫描 AST，判断是否包含内联/展示数学节点。
;; 用 struct->vector 做泛型遍历，新增节点类型不必再来这里补分支。
(define (contains-math? x)
  (cond
    [(node-inline-math? x) #t]
    [(node-display-math? x) #t]
    [(list? x) (ormap contains-math? x)]
    [(struct? x) (ormap contains-math? (cdr (vector->list (struct->vector x))))]
    [else #f]))

(define (math-scripts-lines engine level)
  (at level
      (case engine
        [(none) '()]
        [(katex)
         (list
          "<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.css\">"
          "<script defer src=\"https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.js\"></script>"
          "<script defer src=\"https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/contrib/auto-render.min.js\""
          "  onload=\"renderMathInElement(document.body, {delimiters:[{left:'\\\\(' , right:'\\\\)', display:false},{left:'\\\\[', right:'\\\\]', display:true}], throwOnError:false});\"></script>")]
        [(mathjax)
         (list
          "<script>"
          "  window.MathJax = {tex: {inlineMath: [['\\\\(', '\\\\)']], displayMath: [['\\\\[', '\\\\]']]}};"
          "</script>"
          "<script defer src=\"https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-chtml.js\"></script>")]
        [else (error "render-html: 未知的数学引擎" engine)])))

;; ---------- 页面外壳 ----------

;; 页面顶部元信息块（发布/更新日期等）。字段可扩展，缺失的自动跳过。
(define (meta-field-lines meta level)
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
  (define shown (filter cdr fields))
  (if (empty? shown)
      '()
      (append
       (at level (list "<div class=\"page-meta\">"))
       (at (add1 level)
           (for/list ([f (in-list shown)])
             (format "~a：~a" (car f) (cdr f))))
       (at level (list "</div>")))))

(define (render-document doc)
  (unless (node-document? doc)
    (error "render-html: 期望 document 节点，得到" doc))
  (define meta (node-document-metadata doc))
  (define title (node-metadata-title meta))
  (define base (current-base))
  (define body (node-document-body doc))
  (define numbered? (node-metadata-numbered meta))
  (define index-page? (equal? (current-output-name) "index"))
  (define has-math? (contains-math? body))
  (define engine (let ([m (node-metadata-math meta)])
                   (if (eq? m 'auto) (current-math-engine) m)))
  (when (and has-math? (eq? engine 'none))
    (eprintf "WARNING: 页面“~a”使用了数学节点，但没有设置数学引擎（metadata #:math 或站级配置），公式将不会渲染。\n" title))
  (define lines
    (append
     (at 0 (list "<html lang=\"zh\">"))
     (at 1 (list "<head>"))
     (at 2 (list
            "<meta charset=\"UTF-8\">"
            (format "<title>~a - ~a</title>"
                    (escape-text title) (escape-text (current-site-title)))
            (format "<link href=\"~a\" rel=\"stylesheet\" id=\"css\">"
                    (escape-attr (string-append base (current-css-path))))
            (format "<link rel=\"shortcut icon\" href=\"~a\">"
                    (escape-attr (string-append base (current-favicon))))))
     (if (and (current-author) (not (equal? (current-author) "")))
         (at 2 (list (format "<meta name=\"author\" content=\"~a\">"
                             (escape-attr (current-author)))))
         '())
     (if (and has-math? (not (eq? engine 'none)))
         (math-scripts-lines engine 2)
         '())
     (at 1 (list "</head>"))
     (list "")
     (at 1 (list "<body>"))
     (at 2 (list "<header>"))
     (at 3 (list (format "<h1>~a - ~a</h1>"
                         (escape-text title) (escape-text (current-site-title)))))
     (if index-page?
         '()
         (at 3 (list (format "<a class=\"home-button\" href=\"~a\">回到首页</a>"
                             (escape-attr (string-append base "index.html"))))))
     ;; 文章页：更晚/更早的一篇、元信息都在标题下方、水平线之上；站点页两者为空
     (post-nav-lines 3)
     (meta-field-lines meta 3)
     (at 2 (list "</header>"))
     (at 2 (list "<hr>"))
     (list "")
     (at 2 (list "<main>"))
     (blocks-lines body '() numbered? 3)
     (at 2 (list "</main>"))
     (at 1 (list "</body>"))
     (at 0 (list "</html>"))))
  (string-append "<!DOCTYPE html>\n\n" (join-lines lines)))
