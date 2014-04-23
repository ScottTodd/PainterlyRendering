$ = require 'jquery'
{ read } = require '../meta'
{ makeSlider, onSliderChange } = require './sliderHelp'

module.exports = class RangeRange
	constructor: (opts) ->
		@_name = opts.name

		@_nameDiv =
			$ '<div class=controlName/>'
		@_nameDiv.text @_name

		@_average =
			makeSlider 'average', opts.min, opts.max, opts.startAverage
		@_variance =
			makeSlider 'variance', opts.min, opts.max, opts.startVariance

		@_readOut =
			$ '<div class=readOut/>'

		@_change =
			$.Callbacks()
		onChange = =>
			@_change.fire @get()
		onSliderChange @_average, onChange
		onSliderChange @_variance, onChange
		@_change.add =>
			#maxVary = Math.min @_average.val(), (1 - @_average.val())
			#@_variance.attr 'max', maxVary
			@_readOut.text "#{@_average.val()}±#{@_variance.val()}"

		@_change.fire()

		@_div =
			($ '<div class=rangeRange/>')
		@_div.append @_nameDiv, @_average, @_variance, @_readOut

	read @, 'change', 'div', 'name'

	###
	@return [Number, Number]
	  The current minimum and maximum in the selected range.
	  (Not the minimum and maximum of selector.)
	###
	get: ->
		avg =
			parseFloat @_average.val()
		vary =
			parseFloat @_variance.val()

		low =
			avg - vary#Math.max 0, avg - vary
		high =
			avg + vary#Math.min 1, avg + vary

		[ low, high ]
