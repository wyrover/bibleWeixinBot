
###
@class WeBotShell 测试辅助
###
WeBotShell = ->
xml2js = require("xml2js")
xmlParser = new xml2js.Parser()
_ = require("underscore")._
request = require("request")
crypto = require("crypto")

###
@method makeAuthQuery 组装querystring
@param {String} token 微信token
###
WeBotShell.makeAuthQuery = (token, timestamp, nonce) ->
  obj =
    token: token
    timestamp: timestamp or new Date().getTime().toString()
    nonce: nonce or parseInt((Math.random() * 10e10), 10).toString()
    echostr: "echostr_" + parseInt((Math.random() * 10e10), 10).toString()

  s = [obj.token, obj.timestamp, obj.nonce].sort().join("")
  obj.signature = crypto.createHash("sha1").update(s).digest("hex")
  obj


###
@method makeRequest 获取发送请求的函数

@param  {String}   url   服务地址
@param  {Object}   token 微信token
@return {Function} 发送请求的回调函数,签名为function(info, cb(err, result))

- info {Object} 要发送的内容:

- sp    {String} 微信公众平台ID
- user  {String} 用户ID
- type  {String} 消息类型: text / location / image
- text  {String} 文本消息的内容
- xPos  {Number} 地理位置纬度
- yPos  {Number} 地理位置经度
- scale {Number} 地图缩放大小
- label {String} 地理位置信息
- pic   {String} 图片链接

- cb {Function} 回调函数

- err {Error} 错误消息
- result {Object} 服务器回传的结果,JSON

- return content {String} 返回发送的XML
###
WeBotShell.makeRequest = (url, token) ->
  (info, cb) ->
    
    #默认值
    info = (if _.isString(info) then text: info else info)
    _.defaults info,
      sp: "webot"
      user: "client"
      type: "text"
      text: "help"

    content = _.template(WeBotShell.TEMPLATE)(info)
    
    #发送请求
    request.post
      url: url
      qs: WeBotShell.makeAuthQuery(token)
      body: content
    , (err, res, body) ->
      if err or res.statusCode is "403" or not body
        cb err or res.statusCode, body
      else
        xmlParser.parseString body, (err, result) ->
          if err or not result or not result.xml
            cb err or "result format incorrect", result
          else
            json = result.xml
            json.ToUserName = json.ToUserName and String(json.ToUserName)
            json.FromUserName = json.FromUserName and String(json.FromUserName)
            json.CreateTime = json.CreateTime and Number(json.CreateTime)
            json.FuncFlag = json.FuncFlag and Number(json.FuncFlag)
            json.MsgType = json.MsgType and String(json.MsgType)
            json.Content = json.Content and String(json.Content)
            if json.MsgType is "news"
              json.ArticleCount = json.ArticleCount and Number(json.ArticleCount)
              json.Articles = json.Articles and json.Articles.length >= 1 and json.Articles[0]
            cb err, json


    content


###
@property {String} tpl XML模版
###
WeBotShell.TEMPLATE = ["<xml>", "<ToUserName><![CDATA[<%=sp%>]]></ToUserName>", "<FromUserName><![CDATA[<%=user%>]]></FromUserName>", "<CreateTime><%=(new Date().getTime())%></CreateTime>", "<MsgType><![CDATA[<%=type%>]]></MsgType>", "<% if(type==\"text\"){ %>", "<Content><![CDATA[<%=text%>]]></Content>", "<% }else if(type==\"location\"){  %>", "<Location_X><%=xPos%></Location_X>", "<Location_Y><%=yPos%></Location_Y>", "<Scale><%=scale%></Scale>", "<Label><![CDATA[<%=label%>]]></Label>", "<% }else if(type==\"event\"){  %>", "<Event><![CDATA[<%=event%>]]></Event>", "<EventKey><![CDATA[<%=eventKey%>]]></EventKey>", "<% }else if(type==\"image\"){  %>", "<PicUrl><![CDATA[<%=pic%>]]></PicUrl>", "<% } %>", "</xml>"].join("")
module.exports = exports = WeBotShell
