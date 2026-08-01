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
(struct node-code-block (lang code) #:transparent)
(struct node-display-math (tex) #:transparent)
(struct node-horizontal-line () #:transparent)
(struct node-itemize (items) #:transparent)

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
(struct node-image (src alt title width height) #:transparent)

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
(define (code-block #:lang [lang #f] code) (node-code-block lang code))
(define ($$ tex) (node-display-math tex))
(define (horizontal-line) (node-horizontal-line))
(define (itemize . items) (node-itemize items))

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
(define (image src #:alt [alt #f] #:title [title #f] #:width [width #f] #:height [height #f])
  (node-image src (or alt src) title width height))
