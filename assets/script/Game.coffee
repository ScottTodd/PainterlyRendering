three = require 'three'
{ type } = require './check'
Graphics = require './Graphics'
GameObject = require './GameObject'
Resources = require './Resources'

module.exports = class Game
	constructor: ->
		@graphics =
			new Graphics

		@gameObjects =
			[]

		@resources =
			new Resources @allResources()

		@ready = @resources.promise().then =>
			@restart()

	###
	Every resource this game uses.
	See example in MeshGame.coffee.
	###
	allResources: ->
		models: [ ]
		textures: [ ]

	addObject: (obj) ->
		type obj, GameObject
		@gameObjects.push obj
		obj.registerGame @
		obj.addToGraphics @graphics

	###
	@param div [jquery.Selector]
	###
	bindToDiv: (div) ->
		@ready.then =>
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
		@ready.then =>
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