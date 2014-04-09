three = require 'three'
StrokeMesh = require './StrokeMesh'

module.exports = class GameObject
	constructor: ->
		# currently empty

	createAsSphere: (center, radius) ->
		@center = center
		@radius = radius

	addOriginalObjectToParent: (originalMeshesParent) ->
		@createOriginalObject()

		originalMeshesParent.add @originalObject

	addStrokeObjectToParent: (strokeMeshesParent) ->
		@createStrokeObject()

		strokeMeshesParent.add @strokeObject

	createOriginalObject: ->
		@originalGeometry =
			new three.SphereGeometry @radius, 32, 32
		@originalMaterial =
			new three.MeshBasicMaterial
				color: 0x202022
		@originalMesh =
			new three.Mesh @originalGeometry, @originalMaterial

		@originalObject =
			new three.Object3D()
		@originalObject.add @originalMesh

		@originalObject.translateX @center.x
		@originalObject.translateY @center.y
		@originalObject.translateZ @center.z

	createStrokeObject: ->
		@strokeMesh =
			new StrokeMesh @radius

		@strokeObject =
			new three.Object3D()
		@strokeObject.add @strokeMesh.strokeSystem

		@strokeObject.translateX @center.x
		@strokeObject.translateY @center.y
		@strokeObject.translateZ @center.z
