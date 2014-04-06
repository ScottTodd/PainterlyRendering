express = require 'express'
path = require 'path'
errorHandler = require 'errorhandler'
morgan = require 'morgan'

port =
	3000

app =
	express()

rootPath =
	process.cwd()

# Log requests
app.use morgan 'tiny'
# Statically serve everything in 'public'
app.use express.static path.join rootPath, 'public'
# Dump errors
app.use errorHandler
	dumpExceptions: yes
	showStack: yes

app.listen port, ->
	console.log "Serving on port #{port}..."
