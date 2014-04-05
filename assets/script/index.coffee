$ = require 'jquery'
three = require 'three'
require './vendor/TrackballControls' # creates three.TrackballControls
Graphics = require './Graphics'

class Game
	constructor: (container) ->
		@graphics = new Graphics container

		#@controls =
		#	new three.TrackballControls @graphics.camera
		#@controls.target.set 0, 0, 0

		@done =
			no

	play: ->
		@render()

	render: ->
		unless @done
			requestAnimationFrame =>
				@render()

			try
				#@controls.update()
				@graphics.draw()

			catch error
				@done = yes
				throw error



$ ->
	(new Game $ '#glContainer').play()

