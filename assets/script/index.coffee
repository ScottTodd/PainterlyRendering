$ = require 'jquery'
TestGame = require './games/TestGame'
MeshGame = require './games/MeshGame'
BouncingBunnyGame = require './games/BouncingBunnyGame'
BouncingBallsGame = require './games/BouncingBallsGame'
ParametersGame = require './games/ParametersGame'
TextureGame = require './games/TextureGame'

game =
	new ParametersGame

($ 'document').ready ->
	($ playButton).hide()

	game.bindToDiv $ '#glContainer'

	pause = ->
		($ '#playButton').show()
		($ '#pauseButton').hide()
		game.pause()

	($ '#stopButton').hide()
	($ '#stopButton').click ->
		game.restart()
		pause()

	($ '#playButton').click ->
		($ '#pauseButton').show()
		($ '#playButton').hide()
		game.play()

	($ '#pauseButton').click pause

	game.play()
