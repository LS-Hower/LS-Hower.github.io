#lang racket

;; 整站构建的冒烟测试：把仓库的源文件复制到临时目录，在那里跑一遍 build.rkt，
;; 然后检查每个页面的骨架、锚点唯一性，以及站内链接是否都能落到实处。
;; 运行：raco test tests

(require rackunit
         racket/file
         racket/list
         racket/path
         racket/port
         racket/string)

(module+ test

  ;; ---------- 定位仓库与准备临时目录 ----------

  (define (find-repo-root [start (current-directory)])
    (let loop ([dir (simplify-path start)])
      (cond
        [(file-exists? (build-path dir "tools" "build.rkt")) dir]
        [else
         (define parent (simplify-path (build-path dir 'up)))
         (if (equal? parent dir)
             (error 'site-test "找不到仓库根（缺少 tools/build.rkt）")
             (loop parent))])))

  (define source-files '("main.css" "favicon.ico" "CNAME"))
  (define source-dirs '("tools" "posts" "pages" "assets"))

  (define (copy-sources! root dest)
    (for ([f (in-list source-files)])
      (copy-file (build-path root f) (build-path dest f)))
    (for ([d (in-list source-dirs)])
      (copy-directory/files (build-path root d) (build-path dest d)))
    ;; 仓库里可能有字节码缓存，别一起带过去
    (define caches
      (for/list ([p (in-directory dest)]
                 #:when (and (directory-exists? p)
                             (equal? (path->string (file-name-from-path p)) "compiled")))
        p))
    (for ([c (in-list caches)]) (delete-directory/files c)))

  (define (build-in! dest)
    (parameterize ([current-directory dest]
                   [current-output-port (open-output-nowhere)]
                   [current-error-port (open-output-nowhere)])
      (dynamic-require "tools/build.rkt" #f)))

  ;; ---------- 读取产物 ----------

  (define (stems dir suffix)
    (sort
     (for/list ([f (in-list (directory-list dir))]
                #:when (and (file-exists? (build-path dir f))
                            (string-suffix? (path->string f) suffix)))
       (define name (path->string f))
       (substring name 0 (- (string-length name) (string-length suffix))))
     string<?))

  (define (html-files dest)
    (append
     (for/list ([s (in-list (stems (build-path dest "blog") ".html"))])
       (build-path dest "blog" (format "~a.html" s)))
     (for/list ([s (in-list (stems (build-path dest "site") ".html"))])
       (build-path dest "site" (format "~a.html" s)))
     (list (build-path dest "index.html"))))

  (define (site-links html)
    (append
     (regexp-match* #rx"<a[^>]*href=\"([^\"]*)\"" html #:match-select cadr)
     (regexp-match* #rx"<img[^>]*src=\"([^\"]*)\"" html #:match-select cadr)))

  (define (external-link? s)
    (or (string=? s "")
        (string-prefix? s "#")
        (regexp-match? #rx"^[A-Za-z][A-Za-z0-9+.-]*:" s)))

  ;; ---------- 测试本体 ----------

  (test-case "整站构建：产物齐全、骨架完整、站内链接可达"
    (define root (find-repo-root))
    (define dest (make-temporary-file "lshower-site~a" 'directory))
    (dynamic-wind
      void
      (lambda ()
        (copy-sources! root dest)
        (build-in! dest)

        ;; 产物与源文件一一对应（example 除外）
        (check-equal? (stems (build-path dest "blog") ".html")
                      (sort (remove* '("example") (stems (build-path dest "posts") ".rkt"))
                            string<?)
                      "每篇 posts/*.rkt 都应产出 blog/*.html")
        (check-equal? (stems (build-path dest "site") ".html")
                      (sort (remove* '("index") (stems (build-path dest "pages") ".rkt"))
                            string<?)
                      "每个 pages/*.rkt 都应产出 site/*.html")
        (check-true (file-exists? (build-path dest "index.html")))

        (define checked-links (box 0))
        (for ([f (in-list (html-files dest))])
          (define html (file->string f))
          (define name (path->string (file-name-from-path f)))

          ;; 骨架
          (check-true (string-prefix? html "<!DOCTYPE html>\n") name)
          (check-true (string-suffix? html "</html>\n") name)
          (check-true (string-contains? html "<html lang=\"zh\">") name)
          (check-true (and (string-contains? html "<main>")
                           (string-contains? html "</main>")) name)

          ;; 锚点唯一
          (define ids (regexp-match* #rx"id=\"([^\"]+)\"" html #:match-select cadr))
          (check-equal? (length ids) (length (remove-duplicates ids))
                        (format "~a 里有重复的 id" name))

          ;; 站内链接都能落到文件
          (for ([link (in-list (site-links html))] #:unless (external-link? link))
            (set-box! checked-links (add1 (unbox checked-links)))
            (define target (simplify-path (build-path (path-only f) link)))
            (check-true (file-exists? target)
                        (format "~a 里的链接 ~a 指向不存在的文件" name link))))

        ;; 别让上面的循环空转：至少要检查到一些站内链接
        (check-true (> (unbox checked-links) 0) "没有检查到任何站内链接"))

      (lambda () (delete-directory/files dest)))))
