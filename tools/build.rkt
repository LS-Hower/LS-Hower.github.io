#lang racket

(require "render-html.rkt"
         "notation.rkt"
         racket/list
         racket/string
         racket/match)

;; ---------- 站点配置 ----------

(define site-title "小石")
(define site-author "LS_Hower")
(define css-path "main.css")
(define favicon-path "favicon.ico")
(define math-engine 'none)          ; 'none | 'katex | 'mathjax
(define skip-posts '("example"))    ; 基名列表，跳过不构建

;; ---------- 小工具 ----------

(define (rkt-bases dir)
  (sort
   (for/list ([p (in-list (directory-list dir))]
              #:when (and (not (directory-exists? (build-path dir p)))
                          (string-suffix? (path->string p) ".rkt")))
     (regexp-replace #rx"\\.rkt$" (path->string p) ""))
   string<?))

(define (write-text! path text)
  (call-with-output-file path
    (lambda (o) (display text o))
    #:exists 'replace))

(define (load-page dir base)
  (define doc (dynamic-require (build-path dir (format "~a.rkt" base)) 'page))
  (unless (node-document? doc)
    (error "build: 期望 document 节点，得到" doc))
  doc)

(define (page-meta doc) (node-document-metadata doc))

;; 发布日期：metadata 优先，缺失时回退文件名前缀 YYYY-MM-DD
(define (filename-date base)
  (match (regexp-match #rx"^([0-9]{4})-([0-9]{2})-([0-9]{2})" base)
    [(list _ y m d)
     (node-date (string->number y) (string->number m) (string->number d))]
    [else #f]))

(define (post-publish-date doc base)
  (or (node-metadata-publish-date (page-meta doc))
      (filename-date base)))

(define (date->num d)
  (if (node-date? d)
      (+ (* (node-date-year d) 10000)
         (* (node-date-month d) 100)
         (node-date-day d))
      0))

;; ---------- 收集文章 ----------

(define post-bases (rkt-bases "posts"))
(define post-bases* (filter-not (lambda (b) (member b skip-posts)) post-bases))

(define posts
  (let loop ([bases post-bases*] [acc '()])
    (if (empty? bases)
        (sort acc
              (lambda (a b)
                (define da (date->num (post-rec-publish-date a)))
                (define db (date->num (post-rec-publish-date b)))
                (or (> da db)
                    (and (= da db) (string>? (post-rec-name a) (post-rec-name b))))))
        (let* ([base (car bases)]
               [doc (load-page "posts" base)]
               [title (node-metadata-title (page-meta doc))]
               [pdate (post-publish-date doc base)]
               [udate (node-metadata-update-date (page-meta doc))])
          (loop (cdr bases) (cons (post-rec base title pdate udate) acc))))))

;; ---------- 收集扁平页（除 index 外） ----------

(define page-bases (filter-not (lambda (b) (equal? b "index")) (rkt-bases "pages")))

(define flat-pages
  (for/list ([base (in-list page-bases)])
    (define doc (load-page "pages" base))
    (flat-page-rec base (node-metadata-title (page-meta doc)))))

;; ---------- 渲染 ----------

(define report '())

(define (add-report s) (set! report (cons s report)))

(define (render-post p)
  (define doc (load-page "posts" (post-rec-name p)))
  (define html
    (parameterize ([current-posts posts]
                   [current-flat-pages flat-pages]
                   [current-output-name (post-rec-name p)]
                   [current-base "../"])
      (render-document doc)))
  (write-text! (build-path "blog" (format "~a.html" (post-rec-name p))) html)
  (add-report (format "生成文章：blog/~a.html（~a）" (post-rec-name p) (post-rec-title p))))

(define (render-page p)
  (define doc (load-page "pages" (flat-page-rec-name p)))
  (define html
    (parameterize ([current-posts posts]
                   [current-flat-pages flat-pages]
                   [current-output-name ""]
                   [current-base "../"])
      (render-document doc)))
  (write-text! (build-path "site" (format "~a.html" (flat-page-rec-name p))) html)
  (add-report (format "生成页面：site/~a.html（~a）" (flat-page-rec-name p) (flat-page-rec-title p))))

(define (render-index)
  (define doc (load-page "pages" "index"))
  (define html
    (parameterize ([current-posts posts]
                   [current-flat-pages flat-pages]
                   [current-output-name "index"]
                   [current-base ""])
      (render-document doc)))
  (write-text! (build-path "index.html") html)
  (add-report (format "生成页面：index.html")))

;; ---------- 清理本次未生成的遗留 html ----------

;; 根目录只应有 index.html，其余 .html 均为历史遗留
(define (cleanup-root!)
  (for ([f (in-list (directory-list "."))]
        #:when (and (not (directory-exists? f))
                    (string-suffix? (path->string f) ".html")
                    (not (equal? (path->string f) "index.html"))))
    (delete-file f)
    (add-report (format "删除遗留：~a" (path->string f)))))

;; site/ 下的 .html 全部是生成物，每次清空重写
(define (cleanup-site!)
  (for ([f (in-list (directory-list "site"))]
        #:when (and (not (directory-exists? (build-path "site" f)))
                    (string-suffix? (path->string f) ".html")))
    (delete-file (build-path "site" f))
    (add-report (format "删除遗留：site/~a" (path->string f)))))

(define (cleanup-blog!)
  (for ([f (in-list (directory-list "blog"))]
        #:when (and (not (directory-exists? (build-path "blog" f)))
                    (string-suffix? (path->string f) ".html")))
    (define stem (regexp-replace #rx"\\.html$" (path->string f) ""))
    (unless (member stem post-bases*)
      (delete-file (build-path "blog" f))
      (add-report (format "删除遗留：blog/~a" (path->string f))))))

;; ---------- 主流程 ----------

(define (ensure-dir! dir)
  (unless (directory-exists? dir)
    (make-directory dir)))

(define (main)
  (ensure-dir! "blog")
  (ensure-dir! "site")
  (cleanup-root!)
  (cleanup-site!)
  (cleanup-blog!)
  (for ([p (in-list posts)]) (render-post p))
  (for ([p (in-list flat-pages)]) (render-page p))
  (render-index)
  (displayln (format "=== 构建完成：~a 篇文章、~a 个页面 ==="
                     (length posts) (add1 (length flat-pages))))
  (for ([line (in-list (reverse report))])
    (displayln line)))

(main)
