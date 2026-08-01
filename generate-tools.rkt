#lang racket

(provide
 document
 metadata
 day-date

 paragraph
 section
 quote-block
 code-block
 $$

 code-inline
 italic
 bold
 with-delete-line
 $

 hyperlink
 horizontal-line)

(define (document . args) 'TODO)
(define (metadata . args) 'TODO)
(define (day-date . args) 'TODO)

;; -------- 文档内元素 --------

;; block
(define (paragraph . args) 'TODO)
(define (section . args) 'TODO)
(define (quote-block . args) 'TODO)
(define (code-block . args) 'TODO)
(define ($$ . args) 'TODO)

;; inline
(define (code-inline . args) 'TODO)
(define (italic . args) 'TODO)
(define (bold . args) 'TODO)
(define (with-delete-line . args) 'TODO)
(define ($ . args) 'TODO)

;; 还不知道怎么分类
(define (hyperlink . args) 'TODO)
(define (horizontal-line . args) 'TODO)
