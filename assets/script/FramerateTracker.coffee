$ = require 'jquery'
three = require 'three'
GameObject = require './GameObject'

module.exports = class FramerateTracker extends GameObject
	constructor: (@_selectorText) ->
		@_frameNumber =
			0
		@_currentFrameRate =
			0
		@_clock =
			new three.Clock yes
		@_clock.getDelta()

	step: (dt) ->
		measureEveryNFrames =
			30

		@_frameNumber += 1

		if @_frameNumber % measureEveryNFrames == 0
			elapsed =
				@_clock.getDelta()
			@_currentFrameRate =
				# frames / seconds
				measureEveryNFrames / elapsed

			($ @_selectorText).text Math.round @_currentFrameRate
