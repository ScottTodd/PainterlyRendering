three = require 'three'
Graphics = require './Graphics'

module.exports = class Game
	constructor: ->
		@graphics =
			new Graphics

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
