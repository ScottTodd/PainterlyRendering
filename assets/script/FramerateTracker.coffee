$ = require 'jquery'
three = require 'three'
GameObject = require './GameObject'

module.exports = class FramerateTracker extends GameObject
	constructor: (@selectorText) ->
		@frameNumber =
			0
		# TODO: GameObject
		@clock =
			new three.Clock yes
		@clock.getDelta()
		@_currentFrameRate =
			0

	step: ->
		measureEveryNFrames =
			30

		@frameNumber += 1

		if @frameNumber % measureEveryNFrames == 0
			elapsed =
				@clock.getDelta()
			@_currentFrameRate =
				# frames / seconds
				measureEveryNFrames / elapsed

			($ @selectorText).text Math.round @_currentFrameRate
