$ = require 'jquery'
three = require 'three'
GameObject = require '../GameObject'
SimpleStrokeMeshObject = require '../SimpleStrokeMeshObject'
LayerController = require './LayerController'
Range = require './Range'

module.exports = class ParametersController extends GameObject
	constructor: (@_divName) ->
		null

	start: ->
		meshOptionsDiv =
			$ "<div class='meshOptions'/>"
		@_borderSize =
			new Range
				name: 'Border Size'
				min: 0
				max: 0.5
				start: 0.2
		@_borderSize.change().add =>
			@regenerate()

		meshOptionsDiv.append @_borderSize.div()

		@_layers =
			for idx in [0...3]
				@emit new LayerController @, idx

		@regenerate()

		($ 'document').ready =>
			div = $ "##{@_divName}"
			div.addClass 'parametersController'
			div.empty()
			div.append meshOptionsDiv
			for layer in @_layers
				div.append layer.div()

	regenerate: ->
		if @_obj?
			@_obj.die()

		geometry =
			new three.SphereGeometry 2, 32, 32

		@_obj =
			new SimpleStrokeMeshObject (new three.Vector3 0, 0, 0),
				geometry: geometry
				borderSize: @_borderSize.get()
				layers: layer.opts() for layer in @_layers when layer.on()

		@emit @_obj

