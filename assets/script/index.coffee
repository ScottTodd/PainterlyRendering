$ = require 'jquery'
SpheresGame = require './SpheresGame'

game = new SpheresGame

($ 'document').ready ->
	($ playButton).hide()

	game.bindToDiv $ '#glContainer'

	pause = ->
		($ '#playButton').show()
		($ '#pauseButton').hide()
		game.pause()

	($ '#stopButton').click ->
		game.restart()
		pause()

	($ '#playButton').click ->
		($ '#pauseButton').show()
		($ '#playButton').hide()
		game.play()

	($ '#pauseButton').click pause

	game.play()
