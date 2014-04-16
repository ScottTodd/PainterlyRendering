fs = require 'fs'
$ = require 'jquery'
three = require 'three'
{ check } = require './check'
GameObject = require './GameObject'
{ read } = require './meta'
StrokeMeshLayer = require './StrokeMeshLayer'

module.exports = class StrokeMesh extends GameObject
	###
	opts:
	originalMesh
	strokeLayers
		[ StrokeMeshLayer1, StrokeMeshLayer12, ... ]
	###
	@fromLayers: (opts) ->
		opts.originalMesh ?= opts.strokeLayers[0].getOriginalMesh()

		new StrokeMesh opts

	###
	opts:
		geometry
		layerOptions: [
			nStrokes
			strokeSize
			strokeTexture
		,
			nStrokes
			strokeSize
			strokeTexture
		]
	###
	@fromGeometry: (opts) ->
		# Object properties are constant over all layers
		opts.originalMesh =
			new three.Mesh opts.originalGeometry, new three.MeshBasicMaterial

		# Create strokeLayers using stroke properties
		# Stroke properties are specific to each layer
		opts.strokeLayers =
			[]

		for layerOpts in opts.layerOptions
			nStrokes = layerOpts.nStrokes ? fail()
			strokeSize = layerOpts.strokeSize ? fail()
			strokeTexture = layerOpts.strokeTexture ? fail()

			strokeLayer =
				StrokeMeshLayer.rainbowGeometry
					originalGeometry: opts.originalGeometry
					nStrokes: nStrokes
					strokeSize: strokeSize
					strokeTexture: strokeTexture

			opts.strokeLayers.push strokeLayer

		new StrokeMesh opts

	###
	@private
	Use a factory method instead!
	###
	constructor: (opts) ->
		get = (name, defaultOpt) ->
			if opts[name]?
				opts[name]
			else if defaultOpt?
				defaultOpt()
			else
				throw new Error "Must specify #{name}"

		@_originalMesh = get 'originalMesh'
		@_strokeLayers = get 'strokeLayers'

		@_strokeMeshLayersParent =
			new three.Object3D

		for strokeLayer in @_strokeLayers
			strokeLayer.addToParent @_strokeMeshLayersParent

	addToGraphics: (graphics) ->
		graphics.originalMeshesParent.add @_originalMesh
		graphics.strokeMeshesParent.add @_strokeMeshLayersParent

	getOriginalMesh: ->
		@_originalMesh

	getParentObject: ->
		@_strokeMeshLayersParent

	setPosition: (pos) ->
		@_originalMesh.position.copy pos
		@_strokeMeshLayersParent.position.copy pos
