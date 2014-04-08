three = require 'three'
Graphics = require './Graphics'
GameObject = require './GameObject'

module.exports = class Game
	constructor: ->
		@graphics =
			new Graphics

		@gameObjects =
			[]

		# Create all GameObjects and attach them to Graphics
		sphere1 =
			new GameObject
		center1 =
			new three.Vector3 -0.9, 0, 0
		sphere1.createAsSphere(center1, 2)
		@gameObjects.push sphere1

		sphere2 =
			new GameObject
		center2 =
			new three.Vector3 0.9, 0, -6
		sphere2.createAsSphere(center2, 2)
		@gameObjects.push sphere2

		sphere3 =
			new GameObject
		center3 =
			new three.Vector3 1.4, 0, 0
		sphere3.createAsSphere(center3, 1)
		@gameObjects.push sphere3

		@graphics.attachGameObject gameObject for gameObject in @gameObjects

		@restart()

	###
	@param div [jquery.Selector]
	###
	bindToDiv: (div) ->
		@container = div
		@graphics.bindToDiv div

		@renderOnce()

	restart: ->
		@graphics.restart()

		@paused =
			yes

		@frameNumber =
			0
		@clock =
			new three.Clock yes
		@clock.getDelta()
		@_currentFrameRate =
			0

		if @container?
			# TODO
			# For some reason, can not see first render after pressing 'stop'
			requestAnimationFrame =>
				@renderOnce()

	currentFrameRate: ->
		@_currentFrameRate

	play: ->
		@paused = no
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
		@container.trigger 'render'

		@frameNumber += 1
		@graphics.draw()
		@calculateFrameRate()

	calculateFrameRate: ->
		measureEveryNFrames =
			30

		if @frameNumber % measureEveryNFrames == 0
			elapsed =
				@clock.getDelta()
			@_currentFrameRate =
				# frames / seconds
				measureEveryNFrames / elapsed
