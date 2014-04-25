$ = require 'jquery'
three = require 'three'
GameObject = require './GameObject'
StrokeMeshLayer = require './StrokeMeshLayer'
StrokeMesh = require './StrokeMesh'

module.exports = class PhysicalObject extends GameObject
	###
	opts:
	center
	modelName
	strokeLayerOptions
	mass
	###
	constructor: (@opts) ->

	start: ->
		center = @opts.center ? fail()
		velocity = @opts.velocity ? new three.Vector3 0, 0, 0
		originalGeometry =
			if @opts.model?
				@opts.model
			else if @opts.modelName?
				@resources().geometry @opts.modelName
			else
				fail()
		mass = @opts.mass ? 0
		materialName = @opts.materialName ? fail()
		strokeMeshOptions = @opts.strokeMeshOptions ? fail()

		@mesh =
			StrokeMesh.of $.extend strokeMeshOptions,
				geometry: originalGeometry

		@mesh.addToGraphics @graphics()

		@body =
			@physics().addBody
				gameObject: @
				threeObject: @mesh.threeObject()
				originalGeometry: @mesh.getOriginalMesh().geometry
				mass: mass
				center: center
				velocity: velocity
				materialName: materialName

		if @opts.init?
			@opts.init.call @

	listenForCollide: (callback) ->
		@body.addEventListener 'collide', (event) ->
			callback event.with.gameObject
			#console.log event.contact

	quaternion: ->
		@body.quaternion
