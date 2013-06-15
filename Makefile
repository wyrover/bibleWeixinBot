start:
	@export DEBUG=bible-weixin-bot && npm start

clear:
	@clear

test: clear
	@export DEBUG=bible-weixin-bot && export WX_TOKEN=test123 && ./node_modules/.bin/mocha
