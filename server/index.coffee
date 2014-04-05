express = require 'express'
path = require 'path'
errorHandler = require 'errorhandler'
morgan = require 'morgan'

config = require './config'

app = express()

rootPath = process.cwd()

app.set 'port', config.port
app.set 'views', path.join rootPath, 'assets/view'
app.set 'view engine', 'jade'

# Log requests
app.use morgan 'tiny'
# Statically serve everything in 'public'
app.use express.static path.join rootPath, 'public'
# Dump errors
app.use errorHandler
	dumpExceptions: yes
	showStack: yes

# An HTTP GET request  on the root path will render the 'index' template
app.get '/', (req, res) ->
	res.render 'index'

app.listen (app.get 'port'), ->
	console.log
		port: app.get 'port'
		mode: app.settings.env
