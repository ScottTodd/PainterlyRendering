$ = require 'jquery'
Game = require './Game'

game = new Game

($ 'document').ready ->
	($ playButton).hide()

	glContainer =
		$ '#glContainer'

	game.bindToDiv glContainer

	glContainer.on 'render', ->
		($ '#frameRateNumber').text Math.round game.currentFrameRate()

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
