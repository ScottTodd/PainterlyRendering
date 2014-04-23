q = require 'q'
three = require 'three'
{ type } = require './check'
Graphics = require './Graphics'
GameObject = require './GameObject'
{ read } = require './meta'
Physics = require './Physics'
Resources = require './Resources'

module.exports = class Game
	constructor: ->
		@_graphics =
			new Graphics

		@_resources =
			new Resources @allResources()

		@_readyToPlay = q.defer()

		@_resources.promise().then =>
			@restart()
		# Closes the promise so any errors don't go missing!
		.done()

	read @, 'graphics', 'physics', 'resources'

	###
	Every resource this game uses.
	See example in MeshGame.coffee.
	###
	allResources: ->
		models: [ ]
		textures: [ ]

	addObject: (obj) ->
		type obj, GameObject
		@_gameObjects.push obj
		obj.registerGame @
		obj.start()

	###
	@param div [jquery.Selector]
	###
	bindToDiv: (div) ->
		@container = div

		@_readyToPlay.promise.then =>
			@_graphics.bindToDiv div
			@_graphics.draw()
		.done()

	restart: ->
		@_graphics.restart()

		@_physics =
			new Physics

		@_gameObjects =
			[]

		@addObject @_graphics
		@addObject @_physics

		for obj in @initialObjects()
			@addObject obj

		@otherSetup()

		@_clock =
			new three.Clock yes

		@paused =
			yes

		@_readyToPlay.resolve()

		if @container?
			requestAnimationFrame =>
				@_graphics.draw()

	initialObjects: ->
		[ ]

	otherSetup: ->
		null

	play: ->
		@_readyToPlay.promise.then =>
			@_paused = no
			# Next call to getDelta() will return time taken after this
			@_clock.getDelta()
			@gameLoop()
		.done()

	pause: ->
		@_paused = yes

	gameLoop: ->
		unless @_paused
			requestAnimationFrame =>
				@gameLoop()

			try
				dt =
					@_clock.getDelta()

				for object in @_gameObjects
					object.step dt
				@_gameObjects = @_gameObjects.filter (x) ->
					if x.dead()
						x.finish()
						no
					else
						yes

				@_graphics.draw()

			catch error
				@pause()
				throw error

