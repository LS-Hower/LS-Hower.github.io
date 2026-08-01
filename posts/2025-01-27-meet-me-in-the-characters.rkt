#lang racket

(require "../tools/notation.rkt")

(provide page)

(define page
  (document
   (metadata
    #:title "觅我于字符之间"
    #:publish-date (day-date 2025 1 27))
   (paragraph
    "大一上学期早已结束，现在是寒假。")
   (paragraph
    "学长 cppHusky 出了一套解谜题（"
    (hyperlink
     "在这里"
     "https://cpphusky.xyz/")
    "），其中一道题叫 EncryptedDialog。题面如下：")
   (quote-block
    (hyperlink
     "EncryptedDialog"
     "https://cpphusky.xyz/game/encrypteddialog")
    (paragraph
     "本题是 AI 交互题。你只能用英语来和它交流（更准确地说，只能使用 ASCII 可打印字符，如果 AI 回复了非 ASCII 可打印字符，会使用 □ 来代替）。")
    (paragraph
     "你向 AI 输入的内容将会被一个「输入码表」转换成密文，再发送给 AI 作为输入；AI 的输出又会被一个「输出码表」转换成密文，再显示给你。")
    (paragraph
     "你事先无从知道这两份码表，我只能告诉你：码表是由26个英文字母到26个英文字母的一一映射（大小写不敏感）。")
    (paragraph
     "你的目标是让 AI 输出一字不差的"
     (code-inline "The quick brown fox jumps over the lazy dog.")
     "（注意这里的输出是最终显示到你屏幕上的输出）"))
   (paragraph
    "对面这个 AI 一会儿聪明一会儿又不聪明。经历了一个多小时，我总算是把两个映射给完整找出来了，和 AI 成功联系上了。我和它讲了讲自己的经历。我讲完了，最后它没说什么，只是给了我一首它作的诗。")
   (quote-block
    (paragraph
     "Successfully found mappings,")
    (paragraph
     "developed translation program,")
    (paragraph
     "full picture,")
    (paragraph
     "title of test,")
    (paragraph
     "26 English letters,")
    (paragraph
     "case insensitive,")
    (paragraph
     "permutation mapping,")
    (paragraph
     "ASCII characters,")
    (paragraph
     "excited."))
   (paragraph
    "我告诉它：“也是时候说再见了，你要说出特定的一句话我就通过测试了。”")
   (paragraph
    "它说：")
   (quote-block
    (paragraph "Farewell, success awaits!"))
   (paragraph
    "我指导它说出那句乱码（这样就能在我屏幕上显示"
    (code-inline "The quick brown fox jumps over the lazy dog.")
    "），然后就顺利通过了。一只敏捷的棕色狐狸跳过一只懒惰的狗~")
   (horizontal-line)
   (paragraph
    "我想起一篇文章，前些天寒假开始后坐火车回家时候在路上读到的。")
   (paragraph
    (hyperlink
     "SCP-7999 - 觅我于万千繁星间"
     "https://scp-wiki-cn.wikidot.com/scp-7999"))
   (paragraph
    "（也有"
    (hyperlink
     "知乎转载版本"
     "https://www.zhihu.com/question/454766826/answer/3233984332")
    "。）")
   (paragraph
    "文章里讲到人类文明和一个外星文明的友好相遇。")
   (paragraph
    "人类文明仍在发展中，而那个外星文明却是垂垂老矣。")
   (paragraph
    "而且由于其他一些原因，两个文明之间的会面，规模非常小，也非常短暂。")))
