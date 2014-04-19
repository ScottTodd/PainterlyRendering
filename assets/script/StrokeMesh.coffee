$ = require 'jquery'
three = require 'three'
{ check, type } = require './check'
GameObject = require './GameObject'
{ read } = require './meta'
StrokeMeshLayer = require './StrokeMeshLayer'
DepthBufferMesh = require './DepthBufferMesh'

module.exports = class StrokeMesh extends GameObject
	###
	@param opts
	any StrokeMeshLayer options
	layers:
		0: any layer-specific StrokeMeshLayer options
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
		@_depthMesh =
			new DepthBufferMesh @_originalMesh.geometry

		@_depthMesh.mesh.scale = new three.Vector3 1.01, 1.01, 1.01

		@_threeObject =
			new three.Object3D

	read @, 'threeObject'

	addToGraphics: (graphics) ->
		graphics.strokeMeshes.push @

		@_strokeMeshLayersParent =
			new three.Object3D
		for strokeLayer in @_strokeLayers
			strokeLayer.setupUsingGraphics graphics
			strokeLayer.addToParent @_strokeMeshLayersParent

		if @originalPosition?
			@_threeObject.position.copy @originalPosition
		@_threeObject.add @_originalMesh
		@_threeObject.add @_depthMesh.mesh
		@_threeObject.add @_strokeMeshLayersParent

		graphics.scene.add @_threeObject

	setOriginalMeshVisibility: (visibility) ->
		@_originalMesh.visible = visibility
		@_originalMesh.traverse (child) ->
			child.visible = visibility

	setDepthMeshVisibility: (visibility) ->
		@_depthMesh.mesh.visible = visibility

	setStrokeMeshVisibility: (visibility) ->
		@_strokeMeshLayersParent.visible = visibility
		@_strokeMeshLayersParent.traverse (child) ->
			child.visible = visibility

	getOriginalMesh: ->
		@_originalMesh

	setPosition: (pos) ->
		@_threeObject.position.copy pos
