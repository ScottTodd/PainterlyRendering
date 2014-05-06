$ = require 'jquery'
{ read } = require '../meta'
{ makeSlider, onSliderChange } = require './sliderHelp'

roundToNearest = (x, step) ->
	Math.round(x / step) * step

module.exports = class Range
	constructor: (opts) ->
		@_name = opts.name
		@_scaleType = opts.scaleType ? 'linear'
		@_min = opts.min ? 0
		@_max = opts.max ? 1
		@_step = opts.step ? 0.01
		start = opts.start ? 0

		unScaledStart =
			# 0-1
			(start - @_min) / (@_max - @_min)

		unScaledStart =
			switch @_scaleType
				when 'linear'
					unScaledStart
				when 'exponential'
					k = 2
					Math.log(unScaledStart * (Math.exp(k) - 1) + 1) / k
				else
					fail()

		@_nameDiv =
			$ "<div class='controlName'/>"
		@_nameDiv.text @_name

		@_slider =
			makeSlider 'slider', 0, 1, unScaledStart, 0.001
		@_change =
			$.Callbacks()

		onSliderChange @_slider, =>
			@_change.fire @get()

		@_readOut =
			$ "<div class='readOut'/>"

		@_change.add =>
			@_readOut.text @get().toString().slice 0, 6

		@_change.fire()

		@_div = $ "<div class='range'/>"
		@_div.append @_nameDiv
		@_div.append @_slider
		@_div.append @_readOut

	read @, 'change', 'div', 'name'

	get: ->
		x =
			parseFloat @_slider.val()


		scaled =
			switch @_scaleType
				when 'linear'
					x
				when 'exponential'
					k = 2
					(Math.exp(x * k) - 1) / (Math.exp(k) - 1)
				else
					fail()

		scaled =
			@_min + scaled * (@_max - @_min)

		roundToNearest scaled, @_step

	set: (val) ->
		@_slider.val val
		@_change.fire val
