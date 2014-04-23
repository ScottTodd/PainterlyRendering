$ = require 'jquery'
{ read } = require '../meta'
{ makeSlider, onSliderChange } = require './sliderHelp'

module.exports = class Range
	constructor: (opts) ->
		@_name = opts.name

		@_nameDiv =
			$ "<div class='controlName'/>"
		@_nameDiv.text @_name

		@_slider =
			makeSlider 'slider', opts.min, opts.max, opts.start, opts.step
		@_change =
			$.Callbacks()

		onSliderChange @_slider, =>
			@_change.fire @get()

		@_readOut =
			$ "<div class='readOut'/>"

		@_change.add =>
			@_readOut.text @get()

		@_change.fire()

		@_div = $ "<div class='range'/>"
		@_div.append @_nameDiv
		@_div.append @_slider
		@_div.append @_readOut

	read @, 'change', 'div', 'name'

	get: ->
		parseFloat @_slider.val()

	set: (val) ->
		@_slider.val val
		@_change.fire val
