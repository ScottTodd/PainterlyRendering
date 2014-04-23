$ = require 'jquery'
three = require 'three'
GameObject = require '../GameObject'
SimpleStrokeMeshObject = require '../SimpleStrokeMeshObject'
LayerController = require './LayerController'

module.exports = class ParametersController extends GameObject
	constructor: (@_divName) ->
		null

	start: ->
		@_layers =
			for idx in [0...3]
				@emit new LayerController @, idx

		@regenerate()

		($ 'document').ready =>
			div = $ "##{@_divName}"
			div.addClass 'parametersController'
			div.empty()
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
				layers: layer.opts() for layer in @_layers

		@emit @_obj

