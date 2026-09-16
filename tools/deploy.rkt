#lang racket

(require racket/file
         racket/list
         racket/string
         racket/system)

;; 部署脚本：构建站点，并把发布内容以单个提交强推到 origin 的 gh-pages 分支。
;; 用法（仓库任意位置均可）：
;;     racket tools/deploy.rkt

;; ---------- 定位仓库根（本脚本所在目录的上一级） ----------

(define script-path (find-system-path 'run-file))
(define repo-root (simplify-path (build-path (path-only (path->complete-path script-path)) 'up)))

;; ---------- 需要发布到 gh-pages 的内容（相对仓库根） ----------

(define deploy-files '("index.html" "main.css" "favicon.ico" "CNAME"))
(define deploy-dirs '("blog" "site" "assets"))

;; ---------- 小工具 ----------

;; Windows 上 system* 不做 PATHEXT 查找，故先解析 git 的完整路径
(define git (or (find-executable-path "git") (error 'deploy "找不到 git 可执行文件")))

(define (run . args)
  (unless (apply system* args)
    (error 'deploy "命令失败：~a" (string-join args " "))))

;; 运行命令并捕获 stdout
(define (capture cmd)
  (define handles (process cmd))
  (define stdout (list-ref handles 0))
  (define stdin (list-ref handles 1))
  (define stderr (list-ref handles 3))
  (close-output-port stdin)
  (define text (port->string stdout))
  (close-input-port stdout)
  (when stderr (port->string stderr))
  (string-trim text))

;; ---------- 主流程 ----------

(define (main)
  (current-directory repo-root)

  (displayln "==> 构建站点")
  (run (find-system-path 'exec-file)
       (path->string (build-path repo-root "tools" "build.rkt")))

  (define origin-url (capture "git remote get-url origin"))
  (unless (string-prefix? origin-url "http")
    (error 'deploy "无法获取 origin 的 URL：~a" origin-url))

  (define tmp (make-temporary-file "lshower-deploy~a" 'directory))
  (displayln (format "==> 暂存发布内容到 ~a" tmp))
  (for ([f (in-list deploy-files)])
    (copy-file (build-path repo-root f) (build-path tmp f)))
  (for ([d (in-list deploy-dirs)])
    (copy-directory/files (build-path repo-root d) (build-path tmp d)))

  (parameterize ([current-directory tmp])
    (displayln "==> 提交到临时仓库")
    (run git "init" "-q")
    (run git "add" "-A")
    (run git "commit" "-q" "-m" "deploy")
    (displayln "==> 强推到 origin 的 gh-pages 分支")
    (run git "push" "-f" origin-url "HEAD:gh-pages"))

  (delete-directory/files tmp)
  (displayln "==> 完成。若这是首次部署，请在 GitHub 仓库 Settings → Pages 将发布源设为 gh-pages 分支。"))

(main)
