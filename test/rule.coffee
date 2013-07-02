should = require("should")
token = process.env.WX_TOKEN or "keyboardcat123"
port = process.env.PORT or 3000
bootstrap = require("./bootstrap.js")
makeRequest = bootstrap.makeRequest
sendRequest = makeRequest("http://localhost:" + port, token)
app = require("../app.js")

#公用检测指令
detect = (info, err, json, content) ->
  console.log json
  should.exist info
  should.not.exist err
  should.exist json
  json.should.be.a "object"
  if content
    json.should.have.property "Content"
    json.Content.should.match content


#测试规则
describe "Rule", ->
  
  #初始化
  info = null
  beforeEach ->
    info =
      sp: "bibleWeixinBot"
      user: "client"
      type: "text"

  
  #测试文本消息
  describe "text", ->
    
    #检测more指令
    it "should return more msg", (done) ->
      info.text = "乱七八糟"
      sendRequest info, (err, json) ->
        detect info, err, json, /可用的指令/
        done()

    it "should return help msg", (done) ->
      info.text = "帮助"
      sendRequest info, (err, json) ->
        detect info, err, json, /建议您试试这几条指令/
        done()

    it "should return john 3:16", (done) ->
      info.text = "约翰福音三章十六节"
      sendRequest info, (err, json) ->
        detect info, err, json, /约翰福音 3:16/
        detect info, err, json, /神爱世人/
        done()

    it "should return john 3:16", (done) ->
      info.text = "约 3 : 16 "
      sendRequest info, (err, json) ->
        detect info, err, json, /约翰福音 3:16/
        detect info, err, json, /神爱世人/
        done()

    it "should return john 3:16-21", (done) ->
      info.text = "约翰福音三章十六到二十一节"
      sendRequest info, (err, json) ->
        detect info, err, json, /约翰福音 3:16-21/
        detect info, err, json, /但行真理的必来就光/
        done()

    it "should return john 3:16-21", (done) ->
      info.text = "约 3 ： 16 - 21"
      sendRequest info, (err, json) ->
        detect info, err, json, /约翰福音 3:16-21/
        detect info, err, json, /但行真理的必来就光/
        done()

    it "should return gen 22:17-18", (done) ->
      info.text = "创世记二十二章十七到十八节"
      sendRequest info, (err, json) ->
        detect info, err, json, /创世记 22:17-18/
        detect info, err, json, /地上万国都必因你的后裔得福/
        done()

    it "should return gen 22:17-18", (done) ->
      info.text = "创 22 17 18"
      sendRequest info, (err, json) ->
        detect info, err, json, /创世记 22:17-18/
        detect info, err, json, /地上万国都必因你的后裔得福/
        done()

    it "should return rev 22:19-21", (done) ->
      info.text = "启示录二十二章十九到二十一节"
      sendRequest info, (err, json) ->
        detect info, err, json, /启示录 22:19-21/
        detect info, err, json, /主耶稣啊，我愿你来/
        done()

    it "should return rev 22:19-21", (done) ->
      info.text = "启 22: 19 21"
      sendRequest info, (err, json) ->
        detect info, err, json, /启示录 22:19-21/
        detect info, err, json, /主耶稣啊，我愿你来/
        done()

    it "should return ps 119:29-44", (done) ->
      info.text = "诗篇第一百一十九篇二十九到四十四节"
      sendRequest info, (err, json) ->
        detect info, err, json, /诗篇 119:29-44/
        detect info, err, json, /求你叫真理的话总不离开我口/
        done()

    it "should return ps 119:29-44", (done) ->
      info.text = "诗 119 29 44"
      sendRequest info, (err, json) ->
        detect info, err, json, /诗篇 119:29-44/
        detect info, err, json, /求你叫真理的话总不离开我口/
        done()

    it "should return search", (done) ->
      info.text = "搜索我就是道路。"
      sendRequest info, (err, json) ->
        detect info, err, json, /约翰福音 14:6/
        detect info, err, json, /若不借着我，没有人能到父那里去/
        done()

    it "should return search", (done) ->
      info.text = "S 耶稣基督的家谱"
      sendRequest info, (err, json) ->
        detect info, err, json, /马太福音 1:1/
        done()

  #测试图文消息
  describe "news", ->
    
    #检测首次收听指令
    it "should return subscribe message.", (done) ->
      info.type = "event"
      info.event = "subscribe"
      info.eventKey = ""
      sendRequest info, (err, json) ->
        detect info, err, json
        json.should.have.property "MsgType", "news"
        json.should.have.property "FuncFlag", 0
        json.Articles.item.should.have.length json.ArticleCount
        json.Articles.item[0].Title[0].toString().should.match /感谢您收听/
        done()




