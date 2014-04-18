$ = require 'jquery'
three = require 'three'
{ check, type } = require './check'
GameObject = require './GameObject'
{ read } = require './meta'
StrokeMeshLayer = require './StrokeMeshLayer'

module.exports = class StrokeMesh extends GameObject
	###
	@param opts
	{ any StrokeMeshLayer options }
	layers:
		0: { any layer-specific StrokeMeshLayer options }
		1: etc...
	###
	@of: (opts) ->
		type opts.geometry, three.Geometry

		originalMesh =
			new three.Mesh opts.geometry, new three.MeshBasicMaterial

		layers =
			for layerOpts in opts.layers
				lop =
					$.extend opts, layerOpts

				StrokeMeshLayer.of lop

		new StrokeMesh originalMesh, layers


	###
	@private
	Use a factory method instead!
	###
	constructor: (@_originalMesh, @_strokeLayers) ->
		@_strokeMeshLayersParent =
			new three.Object3D
		for strokeLayer in @_strokeLayers
			strokeLayer.addToParent @_strokeMeshLayersParent

		@threeObject =
			new three.Object3D
		@threeObject.add @_originalMesh
		@threeObject.add @_strokeMeshLayersParent

	addToGraphics: (graphics) ->
		graphics.strokeMeshes.push @
		graphics.scene.add @threeObject

	setOriginalMeshVisibility: (visibility) ->
		@_originalMesh.visible = visibility
		@_originalMesh.traverse (child) ->
			child.visible = visibility

	setStrokeMeshVisibility: (visibility) ->
		@_strokeMeshLayersParent.visible = visibility
		@_strokeMeshLayersParent.traverse (child) ->
			child.visible = visibility

	getOriginalMesh: ->
		@_originalMesh

	setPosition: (pos) ->
		@threeObject.position.copy pos
