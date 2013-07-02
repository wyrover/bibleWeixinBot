debug = require("debug")
log = debug("bible-weixin-bot:log")
_ = require("underscore")._
request = require("request")
exports.chinese2digit = (uchars_chinese) ->
  common_used_numerals ={'零':0,'一':1,'二':2,'三':3,'四':4,'五':5,'六':6,'七':7,'八':8,'九':9,'十':10,'百':100,'千':1000,'万':10000,'亿':100000000}
  total = 0
  r = 1
  for i in [uchars_chinese.length-1..0]
    x = common_used_numerals[uchars_chinese[i]]
    if x >= 10
      if x > r
        r = x
      else
        r = r * x

      if i==0
        total += x
    else
      total += r * x 
    
  total

mongo = require("mongoskin")
mongoDB = mongo.db("localhost:27017/bible",
  safe: true
)
exports.getVerses = (bookName, chapter, startVerse, endVerse, isShortName, callback) ->
  endVerse = startVerse  unless endVerse

  query = 
    version: 'CUNPSS'
    chapter: parseInt(chapter)
    verse:
      $gte: startVerse
      $lte: endVerse

  if isShortName
    query.bookShortName = bookName
  else
    query.bookLongName = bookName

  mongoDB.collection("verse").find(
    $query: query  
    $orderby:
      verse: 1
  ).toArray (err, result) ->
    callback result

exports.getVersesByKeyword = (keyword,callback)->
  keyword = keyword.replace('。','')

  r = new RegExp(keyword)
  query = 
    $query:
      version: 'CUNPSS'
      content: r
    $orderby:
      bookId: 1
      chapter: 1
      verse: 1
  mongoDB.collection("verse").find(query).toArray (err, result) ->
    console.log result
    callback result

exports.getFullVerseName = (bookName,chapter,startVerse,count) ->
  if count==1
    '【'+bookName+' '+chapter+':'+startVerse+'】'
  else if count>1
    '【'+bookName+' '+chapter+':'+startVerse+'-'+(startVerse+count-1)+'】'
  else
    ''
  