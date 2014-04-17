cannon = require 'cannon'
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
		originalGeometry =
			if @opts.model?
				@opts.model
			else if @opts.modelName?
				@resources().geometry @opts.modelName
			else
				fail()
		mass = @opts.mass ? 0
		materialName = @opts.materialName ? fail()
		strokeLayerOptions = @opts.strokeLayerOptions ? fail()

		@mesh =
			StrokeMesh.fromGeometry
				originalGeometry: originalGeometry
				layerOptions: strokeLayerOptions

		@mesh.addToGraphics @graphics()

		@body =
			@physics().addBody
				gameObject: @
				threeObject: @mesh.threeObject
				originalGeometry: @mesh.getOriginalMesh().geometry
				mass: mass
				center: center
				materialName: materialName

		if @opts.init?
			@opts.init.call @

	listenForCollide: (callback) ->
		@body.addEventListener 'collide', (event) ->
			callback event.with.gameObject
			#console.log event.contact

	quaternion: ->
		@body.quaternion
