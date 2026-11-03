#lang racket

;; HTML 渲染（render-html.rkt）的测试：断言产出的片段，而不是整页快照，
;; 这样排版微调不会把测试搞得到处是噪音。
;; 运行：raco test tests

(require rackunit
         racket/port
         racket/string
         "../tools/notation.rkt"
         "../tools/render-html.rkt")

(module+ test

  ;; ---------- 辅助 ----------

  ;; 渲染时把 stderr 吞掉：没配数学引擎的页面会警告，测试输出里不需要这些噪音
  (define (render doc
                  #:name [name "t"]
                  #:base [base ""]
                  #:posts [posts '()]
                  #:pages [pages '()]
                  #:engine [engine 'none]
                  #:author [author ""])
    (parameterize ([current-output-name name]
                   [current-base base]
                   [current-posts posts]
                   [current-flat-pages pages]
                   [current-math-engine engine]
                   [current-author author]
                   [current-error-port (open-output-nowhere)])
      (render-document doc)))

  (define (has? html needle)
    (check-true (string-contains? html needle)
                (format "产出中应包含：~s" needle)))

  (define (lacks? html needle)
    (check-false (string-contains? html needle)
                 (format "产出中不应包含：~s" needle)))

  (define (doc . blocks) (apply document (metadata #:title "标题") blocks))

  ;; ---------- 外壳 ----------

  (test-case "页面外壳：doctype、语言、标题、样式与图标"
    (define html (render (doc (paragraph "x")) #:base "../"))
    (check-true (string-prefix? html "<!DOCTYPE html>\n"))
    (has? html "<html lang=\"zh\">")
    (has? html "<title>标题 - 小石</title>")
    (has? html "<link href=\"../main.css\" rel=\"stylesheet\" id=\"css\">")
    (has? html "<link rel=\"shortcut icon\" href=\"../favicon.ico\">")
    (check-true (string-suffix? html "</html>\n")))

  (test-case "站点页有回到首页的链接，首页没有"
    (has? (render (doc (paragraph "x")) #:name "about") "class=\"home-button\"")
    (lacks? (render (doc (paragraph "x")) #:name "index") "home-button"))

  (test-case "作者信息仅在设置时输出"
    (has? (render (doc (paragraph "x")) #:author "某人")
          "<meta name=\"author\" content=\"某人\">")
    (lacks? (render (doc (paragraph "x"))) "<meta name=\"author\""))

  ;; ---------- 文本与内联 ----------

  (test-case "文本与属性都做转义"
    (define html (render (doc (paragraph "a < b & c > \"d\"")
                              (hyperlink "x" "https://e.com/?a=1&b=2" #:title "t<\"x\">"))))
    (has? html "<p>a &lt; b &amp; c &gt; \"d\"</p>")
    (has? html "href=\"https://e.com/?a=1&amp;b=2\"")
    (has? html "title=\"t&lt;&quot;x&quot;&gt;\""))

  (test-case "内联节点"
    (define html (render (doc (paragraph (bold "粗") (italic "斜") (with-delete-line "删")
                                         (code-inline "c") ($ "x")))))
    (has? html "<strong>粗</strong><em>斜</em><del>删</del> <code>c</code>\\(x\\)"))

  (test-case "链接文字可以是内联序列，且内部也参与盘古之白"
    (define html (render (doc (paragraph "见"
                                         (hyperlink (list "GitHub" (bold " Pages"))
                                                    "https://example.com")))))
    (has? html "<a href=\"https://example.com\">GitHub<strong> Pages</strong></a>")
    (has? html "<p>见 <a href="))

  (test-case "公式与句读之间补空格"
    (has? (render (doc (paragraph ($ "x") "，然后"))) "\\(x\\) ，然后"))

  ;; ---------- 块与缩进 ----------

  (test-case "段落与标题的缩进层级"
    (define html (render (doc (section "一" (paragraph "a")))))
    (has? html "\n      <h2 id=\"sec-1\">1 一</h2>\n")
    (has? html "\n      <p>a</p>\n")
    (has? html "\n    </main>\n"))

  (test-case "章节自动编号与 id，嵌套章节降一级"
    (define html (render (doc (section "一" (section "一·一" (paragraph "a")))
                             (section "二" (paragraph "b")))))
    (has? html "<h2 id=\"sec-1\">1 一</h2>")
    (has? html "<h3 id=\"sec-1-1\">1.1 一·一</h3>")
    (has? html "<h2 id=\"sec-2\">2 二</h2>"))

  (test-case "不编号时标题只有文字"
    (define html (render (document (metadata #:title "t" #:numbered #f)
                                   (section "一" (paragraph "a")))))
    (has? html "<h2 id=\"sec-1\">一</h2>"))

  (test-case "无序列表的缩进"
    (define html (render (doc (list-unordered "项目" (list "甲" (code-inline "b"))))))
    (has? html "\n      <ul>\n        <li>项目</li>\n        <li>甲 <code>b</code></li>\n      </ul>\n"))

  (test-case "有序列表"
    (define html (render (doc (list-ordered "一" "二"))))
    (has? html "\n      <ol>\n        <li>一</li>\n        <li>二</li>\n      </ol>\n"))

  (test-case "引用块内的块再缩进一级"
    (define html (render (doc (quote-block (paragraph "引") (list-unordered "项")))))
    (has? html "\n      <blockquote>\n        <p>引</p>\n        <ul>\n          <li>项</li>\n        </ul>\n      </blockquote>\n"))

  (test-case "水平线"
    (has? (render (doc (horizontal-line))) "\n      <hr>\n"))

  (test-case "代码块内容不被重新缩进"
    (define html (render (doc (code-block #:lang "racket" "  (a)\n(b)"))))
    (has? html "\n      <pre><code class=\"language-racket\">  (a)\n(b)</code></pre>\n"))

  (test-case "无语言的代码块"
    (has? (render (doc (code-block "x"))) "<pre><code>x</code></pre>"))

  (test-case "展示公式"
    (has? (render (document (metadata #:title "t" #:math 'katex) ($$ "x^2")))
          "<p class=\"math-display\">\\[x^2\\]</p>"))

  (test-case "图片：无图注时是段落，有图注时是 figure"
    (define plain (render (doc (image "assets/a.png" #:alt "替代" #:width 42))))
    (has? plain "<p><img src=\"assets/a.png\" alt=\"替代\" style=\"width:42em\"></p>")
    (define captioned (render (doc (image "assets/a.png" #:alt "替代" #:caption "说明" #:title "题"))))
    (has? captioned "\n      <figure>\n        <img src=\"assets/a.png\" alt=\"替代\" title=\"题\">\n        <figcaption>说明</figcaption>\n      </figure>\n"))

  ;; ---------- 表格 ----------

  (test-case "表格：thead/tbody、对齐、单元格换行"
    (define html
      (render (doc (table #:align '(left center)
                          (header-row (cell "头"))
                          (row (cell "体") (cell (list "a" (code-inline "b"))))
                          (row (cell-multi-line (list "一" "二")))))))
    (has? html "\n      <table>\n        <thead>\n")
    (has? html "<th style=\"text-align:left\">头</th>")
    (has? html "<td style=\"text-align:center\">a<code>b</code></td>")
    (has? html "<td style=\"text-align:left\">一<br>二</td>")
    (has? html "        </thead>\n        <tbody>\n"))

  (test-case "表格：未指定对齐时默认左对齐"
    (has? (render (doc (table (header-row (cell "头")) (row (cell "体")))))
          "<td style=\"text-align:left\">体</td>"))

  ;; ---------- 数学引擎 ----------

  (test-case "有公式且设了引擎时才加载脚本"
    (has? (render (document (metadata #:title "t" #:math 'katex) (paragraph ($ "x")))
                  #:engine 'none)
          "katex.min.js")
    (lacks? (render (document (metadata #:title "t" #:math 'katex) (paragraph "无公式")))
            "katex.min.js")
    (lacks? (render (document (metadata #:title "t") (paragraph ($ "x"))) #:engine 'none)
            "katex.min.js"))

  (test-case "表格单元格里的公式也能触发引擎"
    (has? (render (document (metadata #:title "t" #:math 'mathjax)
                            (table (row (cell ($ "x")))))
                  #:engine 'none)
          "mathjax@3"))

  ;; ---------- 自动节点与导航 ----------

  (define sample-posts
    (list (post-rec "a" "甲" (day-date 2026 1 3) #f)
          (post-rec "b" "乙" (day-date 2026 1 2) #f)
          (post-rec "c" "丙" (day-date 2026 1 1) #f)))

  (test-case "文章列表：日期、链接、相对路径"
    (define html (render (doc (posts-list)) #:posts sample-posts #:base "../"))
    (has? html "<li><time>2026-01-03</time> <a href=\"../blog/a.html\">甲</a></li>")
    (has? html "<ul class=\"post-list\">"))

  (test-case "文章列表：#:count 截断"
    (define html (render (doc (posts-list #:count 2)) #:posts sample-posts))
    (has? html "blog/a.html")
    (has? html "blog/b.html")
    (lacks? html "blog/c.html"))

  (test-case "页面链接列表"
    (has? (render (doc (page-links))
                  #:pages (list (flat-page-rec "about" "关于")) #:base "../")
          "<li><a href=\"../site/about.html\">关于</a></li>"))

  (test-case "前后篇导航"
    (define html (render (doc (paragraph "x")) #:name "b" #:posts sample-posts))
    (has? html "class=\"prev\" href=\"blog/a.html\"")
    (has? html "class=\"next\" href=\"blog/c.html\"")
    (has? (render (doc (paragraph "x")) #:name "a" #:posts sample-posts)
          "<span class=\"prev\">‹ 更晚的一篇：无</span>")
    (has? (render (doc (paragraph "x")) #:name "c" #:posts sample-posts)
          "<span class=\"next\">› 更早的一篇：无</span>")
    (lacks? (render (doc (paragraph "x")) #:name "about" #:posts sample-posts)
            "<nav class=\"post-nav\">"))

  (test-case "日期元信息"
    (define html (render (document (metadata #:title "t"
                                             #:publish-date (day-date 2026 1 2)
                                             #:update-date (day-date 2026 1 3))
                                   (paragraph "x"))))
    (has? html "<time pubdate>2026-01-02</time>")
    (has? html "<time>2026-01-03</time>")))
