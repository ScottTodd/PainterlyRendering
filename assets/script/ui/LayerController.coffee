$ = require 'jquery'
GameObject = require '../GameObject'
{ read } = require '../meta'
Range = require './Range'
RangeRange = require './RangeRange'

module.exports = class LayerController extends GameObject
	constructor: (@_paramsControl) ->
		strokeDiv =
			$ "<div class='stroke'/>"
		strokeDiv.append ($ "<div class='strokeTitle'/>").text "Stroke"
		@_nStrokes =
			new Range
				name: 'Number'
				min: 0
				max: 2000
				start: 200
				step: 1
		@_strokeSize =
			new Range
				name: 'Size'
				min: 50
				max: 300
				start: 200
		strokeDiv.append @_nStrokes.div(), @_strokeSize.div()

		hslDiv =
			$ "<div class='hsl'/>"
		hslDiv.append ($ "<div class='hslTitle'/>").text "Colors"
		@_hue =
			new RangeRange
				name: 'Hue'
				min: 0
				max: 1
		@_sat =
			new RangeRange
				name: 'Sat'
				min: 0
				max: 1
				startAverage: 0.5
		@_lum =
			new RangeRange
				name: 'Lum'
				min: 0
				max: 1
				startAverage: 0.25
		hslDiv.append @_hue.div(), @_sat.div(), @_lum.div()

		specDiv =
			$ "<div class='specular'/>"
		specDiv.append ($ "<div class='sectionTitle'/>").text "Specular"
		@_specIntense =
			new Range
				name: 'Amount'
				min: 0
				max: 10
				start: 1
		@_specPow =
			new Range
				name: 'Power'
				min: 0
				max: 10
				start: 4
		@_specMin =
			new Range
				name: 'Min'
				min: 0
				max: 10
		@_specFadeIn =
			new Range
				name: 'Fade In'
				min: 0
				max: 5
		specDiv.append \
			@_specIntense.div(),
			@_specPow.div(),
			@_specMin.div(),
			@_specFadeIn.div()


		# Handle events
		allOpts =
			[ @_nStrokes, @_strokeSize, @_hue, @_sat, @_lum,
			  @_specIntense, @_specPow, @_specMin, @_specFadeIn ]

		for x in allOpts
			x.change().add =>
				@_paramsControl.regenerate()

		@_div = $ "<div class='layerController'/>"
		@_div.append strokeDiv, hslDiv, specDiv

	read @, 'div'

	opts: ->
		strokeTexture: @resources().texture 'stroke1'
		nStrokes: @_nStrokes.get()
		strokeSize: @_strokeSize.get()
		colors:
			type: 'randomHSL'
			hue: @_hue.get()
			sat: @_sat.get()
			lum: @_lum.get()
		specularIntensity: @_specIntense.get()
		specularPower: @_specPow.get()
		specularMin: @_specMin.get()
		specularFadeIn: @_specFadeIn.get()

