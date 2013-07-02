crypto = require("crypto")
debug = require("debug")
log = debug("bible-weixin-bot:log")
verbose = debug("bible-weixin-bot:verbose")
error = debug("bible-weixin-bot:error")
_ = require("underscore")._
chinese2digit = require("./support").chinese2digit
getVerses = require("./support").getVerses
getVersesByKeyword = require("./support").getVersesByKeyword
getFullVerseName  = require("./support").getFullVerseName
###
初始化路由规则
###
module.exports = exports = (webot) ->

  helpLines = ["建议您试试这几条指令:", "1. 圣经章节 : 输入格式： ‘约3:16-20’ 或 ‘约 3 16 20’，或者使用微信语音输入： 约翰福音三章十六到二十节", "2. 搜索经文内容。格式： ‘搜索 耶稣基督’ 或者 ‘s 耶稣基督',其中空格也可以去掉。 "].join("\n")
  reg_help = /^(help|帮助|\?|？)$/i
  webot.set
    
    # name 和 description 都不是必须的
    name: "hello help"
    description: "获取使用帮助，请发送 help 或者 帮助 或者 ?"
    pattern: (info) ->
      
      #首次关注时,会收到subscribe event
      info.is("event") and info.param.event is "subscribe"

    handler: (info) ->
      reply =
        title: "感谢您收听一粒麦子基督徒微信助手"
        pic: "https://github.com/anderson916/bibleWeixinBot/blob/master/qrcode.jpg"
        description: helpLines

      
      # 返回值如果是list，则回复图文消息列表
      reply

  webot.set /^(help|帮助|\?)$/i, (info) ->
    
    # 利用 error log 收集听不懂的消息，以利于接下来完善规则
    # 你也可以将这些 message 存入数据库
    log "receive message: %s", info.text
    info.flag = true
    helpLines

  webot.set /(创世记|出埃及记|利未记|民数记|申命记|约书亚记|士师记|路得记|撒母耳记上|撒母耳记下|列王记上|列王记下|历代志上|历代志下|以斯拉记|尼希米记|以斯帖记|约伯记|诗篇|箴言|传道书|雅歌|以赛亚书|耶利米书|耶利米哀歌|以西结书|但以理书|何西阿书|约珥书|阿摩司书|俄巴底亚书|约拿书|弥迦书|那鸿书|哈巴谷书|西番雅书|哈该书|撒迦利亚书|玛拉基书|马太福音|马可福音|路加福音|约翰福音|使徒行传|罗马书|哥林多前书|哥林多后书|加拉太书|以弗所书|腓立比书|歌罗西书|帖撒罗尼迦前书|帖撒罗尼迦后书|提摩太前书|提摩太后书|提多书|腓利门书|希伯来书|雅各书|彼得前书|彼得后书|约翰壹书|约翰贰书|约翰叁书|犹大书|启示录)第*(零|一|二|三|四|五|六|七|八|九|十|百)+[章|篇](零|一|二|三|四|五|六|七|八|九|十|百)+到(零|一|二|三|四|五|六|七|八|九|十|百)+/i, (info,next) ->
    r = /(创世记|出埃及记|利未记|民数记|申命记|约书亚记|士师记|路得记|撒母耳记上|撒母耳记下|列王记上|列王记下|历代志上|历代志下|以斯拉记|尼希米记|以斯帖记|约伯记|诗篇|箴言|传道书|雅歌|以赛亚书|耶利米书|耶利米哀歌|以西结书|但以理书|何西阿书|约珥书|阿摩司书|俄巴底亚书|约拿书|弥迦书|那鸿书|哈巴谷书|西番雅书|哈该书|撒迦利亚书|玛拉基书|马太福音|马可福音|路加福音|约翰福音|使徒行传|罗马书|哥林多前书|哥林多后书|加拉太书|以弗所书|腓立比书|歌罗西书|帖撒罗尼迦前书|帖撒罗尼迦后书|提摩太前书|提摩太后书|提多书|腓利门书|希伯来书|雅各书|彼得前书|彼得后书|约翰壹书|约翰贰书|约翰叁书|犹大书|启示录)第*(.*)[章|篇]([零|一|二|三|四|五|六|七|八|九|十|百]+)到([零|一|二|三|四|五|六|七|八|九|十|百]+)/i
    match = r.exec(info.text)
    bookName = match[1]
    chapter = chinese2digit(match[2])
    startVerse = chinese2digit(match[3])
    getVerses bookName,chapter,startVerse,chinese2digit(match[4]),false,(result)->
      info.flag = true
      lines=[]
      lines.push getFullVerseName(bookName,chapter,startVerse,result.length)
      
      for verse in result
        lines.push verse.content
      next null,lines.join("\n")

  webot.set /(创世记|出埃及记|利未记|民数记|申命记|约书亚记|士师记|路得记|撒母耳记上|撒母耳记下|列王记上|列王记下|历代志上|历代志下|以斯拉记|尼希米记|以斯帖记|约伯记|诗篇|箴言|传道书|雅歌|以赛亚书|耶利米书|耶利米哀歌|以西结书|但以理书|何西阿书|约珥书|阿摩司书|俄巴底亚书|约拿书|弥迦书|那鸿书|哈巴谷书|西番雅书|哈该书|撒迦利亚书|玛拉基书|马太福音|马可福音|路加福音|约翰福音|使徒行传|罗马书|哥林多前书|哥林多后书|加拉太书|以弗所书|腓立比书|歌罗西书|帖撒罗尼迦前书|帖撒罗尼迦后书|提摩太前书|提摩太后书|提多书|腓利门书|希伯来书|雅各书|彼得前书|彼得后书|约翰壹书|约翰贰书|约翰叁书|犹大书|启示录)第*(零|一|二|三|四|五|六|七|八|九|十|百)+[章|篇](零|一|二|三|四|五|六|七|八|九|十|百)+/i, (info,next) ->
    r = /(创世记|出埃及记|利未记|民数记|申命记|约书亚记|士师记|路得记|撒母耳记上|撒母耳记下|列王记上|列王记下|历代志上|历代志下|以斯拉记|尼希米记|以斯帖记|约伯记|诗篇|箴言|传道书|雅歌|以赛亚书|耶利米书|耶利米哀歌|以西结书|但以理书|何西阿书|约珥书|阿摩司书|俄巴底亚书|约拿书|弥迦书|那鸿书|哈巴谷书|西番雅书|哈该书|撒迦利亚书|玛拉基书|马太福音|马可福音|路加福音|约翰福音|使徒行传|罗马书|哥林多前书|哥林多后书|加拉太书|以弗所书|腓立比书|歌罗西书|帖撒罗尼迦前书|帖撒罗尼迦后书|提摩太前书|提摩太后书|提多书|腓利门书|希伯来书|雅各书|彼得前书|彼得后书|约翰壹书|约翰贰书|约翰叁书|犹大书|启示录)第*([零|一|二|三|四|五|六|七|八|九|十|百]+)[章|篇]([零|一|二|三|四|五|六|七|八|九|十|百]+)/i
    match = r.exec(info.text)
    bookName = match[1]
    chapter = chinese2digit(match[2])
    startVerse = chinese2digit(match[3])
    getVerses bookName,chapter,startVerse,false,false,(result)->
      info.flag = true
      lines=[]
      lines.push getFullVerseName(bookName,chapter,startVerse,result.length)
      for verse in result
        lines.push verse.content
      next null,lines.join("\n")

  webot.set /([创|出|利|民|申|书|士|得|撒上|撒下|王上|王下|代上|代下|拉|尼|斯|伯|诗|箴|传|歌|赛|耶|哀|结|但|何|珥|摩|俄|拿|弥|鸿|哈|番|该|亚|玛|太|可|路|约|徒|罗|林前|林后|加|弗|腓|西|帖前|帖后|提前|提后|多|门|来|雅|彼前|彼后|约一|约二|约三|犹|启])\s*(\d+)\s*[:|：]*\s*(\d+)\s*[-|——]*\s*(\d+)?/, (info,next) ->
    r = /([创|出|利|民|申|书|士|得|撒上|撒下|王上|王下|代上|代下|拉|尼|斯|伯|诗|箴|传|歌|赛|耶|哀|结|但|何|珥|摩|俄|拿|弥|鸿|哈|番|该|亚|玛|太|可|路|约|徒|罗|林前|林后|加|弗|腓|西|帖前|帖后|提前|提后|多|门|来|雅|彼前|彼后|约一|约二|约三|犹|启])\s*(\d+)\s*[:|：]*\s*(\d+)\s*[-|——]*\s*(\d+)?/
    match = r.exec(info.text)
    bookName = match[1]
    chapter = parseInt(match[2])
    if match[3]
      startVerse = parseInt(match[3])
    else
      startVerse = 1
    if match[4]
      endVerse = parseInt(match[4])
    else
      endVerse = startVerse
    getVerses bookName,chapter,startVerse,endVerse,true,(result)->
      fullName = result[0].bookLongName
      info.flag = true
      lines=[]
      lines.push getFullVerseName(fullName,chapter,startVerse,result.length)
      for verse in result
        lines.push verse.content
      next null,lines.join("\n")
      
  webot.set /[搜索|s|S]\s*(.*)/,(info,next)->
    r = /(搜索|s|S)\s*(.*)/
    match = r.exec(info.text)
    getVersesByKeyword match[2],(result)->
      lines = []
      i=0
      for verse in result
        lines.push getFullVerseName(verse.bookLongName,verse.chapter,verse.verse,1)
        lines.push verse.content
        i = i+1
        if i>3
          break
      next null,lines.join("\n")

  #所有消息都无法匹配时的fallback
  webot.set /.*/, (info) ->
    
    # 利用 error log 收集听不懂的消息，以利于接下来完善规则
    # 你也可以将这些 message 存入数据库
    log "unhandled message: %s", info.text
    info.flag = true
    "您发送了「" + info.text + "」,可惜我现在不能领会. 请发送: 帮助 或者 ？ 查看可用的指令"

