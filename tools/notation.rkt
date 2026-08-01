#lang racket

(provide
 ;; 文档级
 document
 metadata
 day-date

 ;; block
 paragraph
 section
 quote-block
 code-block
 $$
 horizontal-line
 itemize
 table
 header-row
 row
 cell
 cell-multi-line
 enumerate
 terminal-output

 ;; inline
 code-inline
 italic
 bold
 with-delete-line
 $
 hyperlink

 ;; site 级自动节点
 posts-list
 page-links

 ;; 其他
 image)

(provide
 ;; 数据节点（AST）
 (struct-out node-document)
 (struct-out node-metadata)
 (struct-out node-date)
 (struct-out node-section)
 (struct-out node-paragraph)
 (struct-out node-quote-block)
 (struct-out node-code-block)
 (struct-out node-display-math)
 (struct-out node-horizontal-line)
 (struct-out node-itemize)
 (struct-out node-table)
 (struct-out node-row)
 (struct-out node-header-row)
 (struct-out node-cell)
 (struct-out node-enumerate)
 (struct-out node-terminal-output)
 (struct-out node-code-inline)
 (struct-out node-italic)
 (struct-out node-bold)
 (struct-out node-strike)
 (struct-out node-inline-math)
 (struct-out node-hyperlink)
 (struct-out node-posts-list)
 (struct-out node-page-links)
 (struct-out node-image))

;; ---------- 数据节点（AST） ----------

;; block
(struct node-document (metadata body) #:transparent)
(struct node-metadata (title publish-date update-date numbered math) #:transparent)
(struct node-date (year month day) #:transparent)
(struct node-section (title body) #:transparent)
(struct node-paragraph (inlines) #:transparent)
(struct node-quote-block (body) #:transparent)
(struct node-code-block (lang code from-file) #:transparent)
(struct node-display-math (tex) #:transparent)
(struct node-horizontal-line () #:transparent)
(struct node-itemize (items) #:transparent)
(struct node-table (align rows) #:transparent)
(struct node-row (cells) #:transparent)
(struct node-header-row (cells) #:transparent)
(struct node-cell (lines) #:transparent)
(struct node-enumerate (items) #:transparent)
(struct node-terminal-output (run cwd) #:transparent)

;; inline
(struct node-code-inline (code) #:transparent)
(struct node-italic (inlines) #:transparent)
(struct node-bold (inlines) #:transparent)
(struct node-strike (inlines) #:transparent)
(struct node-inline-math (tex) #:transparent)
(struct node-hyperlink (text url title) #:transparent)

;; site 级自动节点（仅用于首页等需要站点上下文的页面）
(struct node-posts-list (count) #:transparent)
(struct node-page-links () #:transparent)

;; 其他
(struct node-image (src alt title width height caption) #:transparent)

;; ---------- 公开记号 ----------

(define (document meta . body) (node-document meta body))

(define (metadata #:title title
                  #:publish-date [publish-date #f]
                  #:update-date [update-date #f]
                  #:numbered [numbered #t]
                  #:math [math 'auto])
  (node-metadata title publish-date update-date numbered math))

(define (day-date year month day) (node-date year month day))

;; block
(define (paragraph . inlines) (node-paragraph inlines))
(define (section title . body) (node-section title body))
(define (quote-block . body) (node-quote-block body))
(define (code-block #:lang [lang #f] #:from-file [from-file #f] [code #f])
  (node-code-block lang code from-file))
(define ($$ tex) (node-display-math tex))
(define (horizontal-line) (node-horizontal-line))
(define (itemize . items) (node-itemize items))
(define (table #:align [align #f] . rows) (node-table align rows))
(define (header-row . cells) (node-header-row cells))
(define (row . cells) (node-row cells))
(define (cell line) (node-cell (list line)))
(define (cell-multi-line lines) (node-cell lines))
(define (enumerate . items) (node-enumerate items))
(define (terminal-output #:run run #:cwd [cwd #f]) (node-terminal-output run cwd))

;; inline
(define (code-inline s) (node-code-inline s))
(define (italic . xs) (node-italic xs))
(define (bold . xs) (node-bold xs))
(define (with-delete-line . xs) (node-strike xs))
(define ($ tex) (node-inline-math tex))
(define (hyperlink text url #:title [title #f]) (node-hyperlink text url title))

;; site 级
(define (posts-list #:count [count +inf.0]) (node-posts-list count))
(define (page-links) (node-page-links))

;; 其他
;; 图片尺寸 #:width/#:height：数字解释为 em（相对文字高度），字符串按 CSS 原样（如 "100%"）
(define (image src #:alt [alt #f] #:title [title #f] #:width [width #f] #:height [height #f]
                #:caption [caption #f])
  (node-image src (or alt src) title width height caption))
