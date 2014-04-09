three = require 'three'
Graphics = require './Graphics'
GameObject = require './GameObject'
{ type } = require './check'

module.exports = class Game
	constructor: ->
		@graphics =
			new Graphics

		@gameObjects =
			[]

		@restart()

	addObject: (obj) ->
		type obj, GameObject
		@gameObjects.push obj
		obj.addToGraphics @graphics

	###
	@param div [jquery.Selector]
	###
	bindToDiv: (div) ->
		@container = div
		@graphics.bindToDiv div

		@renderOnce()

	restart: ->
		@graphics.restart()

		for obj in @initialObjects()
			@addObject obj

		@clock =
			new three.Clock yes

		@paused =
			yes

		if @container?
			# TODO
			# For some reason, can not see first render after pressing 'stop'
			requestAnimationFrame =>
				@renderOnce()

	initialObjects: ->
		[ ]

	play: ->
		@paused = no
		@clock.getDelta() # Next call to getDelta() will return time taken after this
		@renderLoop()

	pause: ->
		@paused = yes

	renderLoop: ->
		unless @paused
			requestAnimationFrame =>
				@renderLoop()

			try
				@renderOnce()

			catch error
				@pause()
				throw error

	renderOnce: ->
		dt =
			@clock.getDelta()

		for object in @gameObjects
			object.step dt

		@graphics.draw()
