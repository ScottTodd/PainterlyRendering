$ = require 'jquery'
GameObject = require '../GameObject'
{ read } = require '../meta'
OnOffButton = require './OnOffButton'
RadioSelector = require './RadioSelector'
Range = require './Range'
RangeRange = require './RangeRange'

module.exports = class LayerController extends GameObject
	constructor: (@_paramsControl, index) ->
		strokeDiv =
			$ "<div class='stroke'/>"
		strokeDiv.append ($ "<div class='controlTitle'
							name='stroke'/>").text "Stroke"

		@_on =
			new OnOffButton
				class: 'layerOn'
				start: index == 0

		@_nStrokes =
			new Range
				name: 'Number'
				min: 0
				max: 15000
				step: 1
				scaleType: 'exponential'
				start: 500 * Math.pow 2, index
		@_strokeSize =
			new Range
				name: 'Size'
				min: 0.04
				max: 0.4
				scaleType: 'exponential'
				start: 0.3 - 0.1 * index #0.4 * Math.pow 0.5, index
		@_strokeTexture =
			new RadioSelector
				name: 'Texture'
				options: [
					'stroke1', 'stroke2', 'stroke3', 'stroke4',
					'stroke5', 'noise1', 'noise2', 'circle',
					'triangle', 'square', 'stick', 'grid'
				]
				start: 'stroke1'
		@_objectTexture =
			new RadioSelector
				name: 'Object Texture'
				options: [
					'none', 'scream', '4colors', 'raytrace',
					'fire', 'water', 'grass', 'brick' # 'ice'
				]
				start: 'none'
		@_strokeRotCurve =
			new RadioSelector
				name: 'Drawing Method'
				options: [ 'flat', 'oriented', 'curved' ]
				start: 'curved'
		@_strokeRotCurve.div().addClass 'short'
		@_strokeCurveFactor =
			new Range
				name: 'Curve'
				min: 0
				max: 2
				scaleType: 'exponential'
				start: 1

		strokeDiv.append ($ "<div class='rangeGroup'/>").append \
			@_nStrokes.div(), @_strokeSize.div()
		strokeDiv.append @_strokeTexture.div()
		#strokeDiv.append ($ "<div class='controlName'/>").text "Stroke"
		strokeDiv.append @_strokeRotCurve.div()
		strokeDiv.append ($ "<div class='rangeGroup'/>").append \
			@_strokeCurveFactor.div()

		hslDiv =
			$ "<div class='hsl'/>"
		hslDiv.append ($ "<div class='controlTitle' name='hsl'/>").text "Colors"
		hslDiv.append @_objectTexture.div()
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
		hslDiv.append ($ "<div class='rangeGroup'/>").append \
			@_hue.div(), @_sat.div(), @_lum.div()
		specDiv =
			$ "<div class='specular'/>"
		specDiv.append \
			($ "<div class='controlTitle' name='specular'/>").text "Specular"
		@_specIntense =
			new Range
				name: 'Amount'
				min: 0
				max: 10
				scaleType: 'exponential'
				start: 2
		@_specPow =
			new Range
				name: 'Power'
				min: 0
				max: 10
				scaleType: 'exponential'
				start: 4
		@_specMin =
			new Range
				name: 'Min'
				min: 0
				max: 10
				scaleType: 'exponential'
		@_specFadeIn =
			new Range
				name: 'Fade In'
				min: 0
				max: 5
				scaleType: 'exponential'
		specDiv.append ($ "<div class='rangeGroup'/>").append \
			@_specIntense.div(),
			@_specPow.div(),
			@_specMin.div(),
			@_specFadeIn.div()

		# Handle events
		allOpts =
			[ @_on, @_nStrokes, @_strokeSize, @_strokeTexture, @_objectTexture,
			  @_strokeRotCurve, @_strokeCurveFactor,
			  @_hue, @_sat, @_lum,
			  @_specIntense, @_specPow, @_specMin, @_specFadeIn ]

		for x in allOpts
			x.change().add =>
				@_paramsControl.regenerate()

		@_div =
			$ "<div class='layerController'/>"
		@_div.append @_on.div(), strokeDiv, hslDiv, specDiv

		@_overlay =
			$ "<div class='layerControllerOverlay'/>"
		@_div.append @_overlay

		showOn = =>
			if @on()
				@_overlay.hide() #.slideUp()
			else
				@_overlay.show() #.slideDown()

		@_on.change().add showOn
		showOn()


	read @, 'div'

	on: ->
		@_on.get()

	opts: ->
		strokeTexture: @resources().texture @_strokeTexture.get()
		objectTexture:
			if @_objectTexture.get() != 'none'
				@resources().texture @_objectTexture.get()
		nStrokes: @_nStrokes.get()
		strokeSize: @_strokeSize.get()
		enableRotation: @_strokeRotCurve.get() != 'flat'
		curveFactor:
			if @_strokeRotCurve.get() == 'curved'
				@_strokeCurveFactor.get()
			else
				0
		colors:
			type: 'randomHSL'
			hue: @_hue.get()
			sat: @_sat.get()
			lum: @_lum.get()
		specularIntensity: @_specIntense.get()
		specularPower: @_specPow.get()
		specularMin: @_specMin.get()
		specularFadeIn: @_specFadeIn.get()
