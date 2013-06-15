crypto = require("crypto")
debug = require("debug")
log = debug("bible-weixin-bot:log")
verbose = debug("bible-weixin-bot:verbose")
error = debug("bible-weixin-bot:error")
_ = require("underscore")._
chinese2digit = require("./support").chinese2digit
getVerses = require("./support").getVerses

###
初始化路由规则
###
module.exports = exports = (webot) ->

  helpLines = ["建议您试试这几条指令:", "1. 圣经章节 : 比如约翰福音3:16-20或者使用微信语音输入约翰福音三章十六到二十节", "2. 赞美诗完整或部分歌名 : 比如奇异恩典，你是我永远的救主 (尚未完成）"].join("\n")
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
        title: "感谢您收听一粒麦子基督徒助手"
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

  webot.set /(创世记|出埃及记|利未记|民数记|申命记|约书亚记|士师记|路得记|撒母耳记上|撒母耳记下|列王记上|列王记下|历代志上|历代志下|以斯拉记|尼希米记|以斯帖记|约伯记|诗篇|箴言|传道书|雅歌|以赛亚书|耶利米书|耶利米哀歌|以西结书|但以理书|何西阿书|约珥书|阿摩司书|俄巴底亚书|约拿书|弥迦书|那鸿书|哈巴谷书|西番雅书|哈该书|撒迦利亚书|玛拉基书|马太福音|马可福音|路加福音|约翰福音|使徒行传|罗马书|哥林多前书|哥林多后书|加拉太书|以弗所书|腓立比书|歌罗西书|帖撒罗尼迦前书|帖撒罗尼迦后书|提摩太前书|提摩太后书|提多书|腓利门书|希伯来书|雅各书|彼得前书|彼得后书|约翰壹书|约翰贰书|约翰叁书|犹大书|启示录)(零|一|二|三|四|五|六|七|八|九|十|百)+章(零|一|二|三|四|五|六|七|八|九|十|百)+到(零|一|二|三|四|五|六|七|八|九|十|百)+节/i, (info,next) ->
    r = /(创世记|出埃及记|利未记|民数记|申命记|约书亚记|士师记|路得记|撒母耳记上|撒母耳记下|列王记上|列王记下|历代志上|历代志下|以斯拉记|尼希米记|以斯帖记|约伯记|诗篇|箴言|传道书|雅歌|以赛亚书|耶利米书|耶利米哀歌|以西结书|但以理书|何西阿书|约珥书|阿摩司书|俄巴底亚书|约拿书|弥迦书|那鸿书|哈巴谷书|西番雅书|哈该书|撒迦利亚书|玛拉基书|马太福音|马可福音|路加福音|约翰福音|使徒行传|罗马书|哥林多前书|哥林多后书|加拉太书|以弗所书|腓立比书|歌罗西书|帖撒罗尼迦前书|帖撒罗尼迦后书|提摩太前书|提摩太后书|提多书|腓利门书|希伯来书|雅各书|彼得前书|彼得后书|约翰壹书|约翰贰书|约翰叁书|犹大书|启示录)(.*)章(.*)到(.*)节/i
    match = r.exec(info.text)
    bookName = match[1]
    chapter = chinese2digit(match[2])
    startVerse = chinese2digit(match[3])
    getVerses bookName,chapter,startVerse,chinese2digit(match[4]),(result)->
      info.flag = true
      lines=[]
      if result.length==1
        lines.push bookName+chapter+':'+startVerse
      else if result.length>1
        lines.push bookName+chapter+':'+startVerse+'-'+result[result.length-1].verse
      for verse in result
        lines.push verse.content
      next null,lines.join("\n")

  webot.set /(创世记|出埃及记|利未记|民数记|申命记|约书亚记|士师记|路得记|撒母耳记上|撒母耳记下|列王记上|列王记下|历代志上|历代志下|以斯拉记|尼希米记|以斯帖记|约伯记|诗篇|箴言|传道书|雅歌|以赛亚书|耶利米书|耶利米哀歌|以西结书|但以理书|何西阿书|约珥书|阿摩司书|俄巴底亚书|约拿书|弥迦书|那鸿书|哈巴谷书|西番雅书|哈该书|撒迦利亚书|玛拉基书|马太福音|马可福音|路加福音|约翰福音|使徒行传|罗马书|哥林多前书|哥林多后书|加拉太书|以弗所书|腓立比书|歌罗西书|帖撒罗尼迦前书|帖撒罗尼迦后书|提摩太前书|提摩太后书|提多书|腓利门书|希伯来书|雅各书|彼得前书|彼得后书|约翰壹书|约翰贰书|约翰叁书|犹大书|启示录)(零|一|二|三|四|五|六|七|八|九|十|百)+章(零|一|二|三|四|五|六|七|八|九|十|百)+节/i, (info,next) ->
    r = /(创世记|出埃及记|利未记|民数记|申命记|约书亚记|士师记|路得记|撒母耳记上|撒母耳记下|列王记上|列王记下|历代志上|历代志下|以斯拉记|尼希米记|以斯帖记|约伯记|诗篇|箴言|传道书|雅歌|以赛亚书|耶利米书|耶利米哀歌|以西结书|但以理书|何西阿书|约珥书|阿摩司书|俄巴底亚书|约拿书|弥迦书|那鸿书|哈巴谷书|西番雅书|哈该书|撒迦利亚书|玛拉基书|马太福音|马可福音|路加福音|约翰福音|使徒行传|罗马书|哥林多前书|哥林多后书|加拉太书|以弗所书|腓立比书|歌罗西书|帖撒罗尼迦前书|帖撒罗尼迦后书|提摩太前书|提摩太后书|提多书|腓利门书|希伯来书|雅各书|彼得前书|彼得后书|约翰壹书|约翰贰书|约翰叁书|犹大书|启示录)(.*)章(.*)节/i
    match = r.exec(info.text)
    bookName = match[1]
    chapter = chinese2digit(match[2])
    startVerse = chinese2digit(match[3])
    getVerses bookName,chapter,startVerse,false,(result)->
      info.flag = true
      lines=[]
      if result.length==1
        lines.push bookName+chapter+':'+startVerse
      else if result.length>1
        lines.push bookName+chapter+':'+startVerse+'-'+result[result.length-1].verse
      for verse in result
        lines.push verse.content
      next null,lines.join("\n")

  #所有消息都无法匹配时的fallback
  webot.set /.*/, (info) ->
    
    # 利用 error log 收集听不懂的消息，以利于接下来完善规则
    # 你也可以将这些 message 存入数据库
    log "unhandled message: %s", info.text
    info.flag = true
    "您发送了「" + info.text + "」,可惜我现在不能领会. 请发送: 帮助 或者 ？ 查看可用的指令"

