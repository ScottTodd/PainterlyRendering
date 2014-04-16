cannon = require 'cannon'
GameObject = require './GameObject'
StrokeMeshLayer = require './StrokeMeshLayer'

module.exports = class PhysicalObject extends GameObject
	###
	opts:
	center
	modelName
	nStrokes
	strokeTextureName
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
		nStrokes = @opts.nStrokes ? fail()
		strokeTextureName = @opts.strokeTextureName ? fail()
		mass = @opts.mass ? 0
		materialName = @opts.materialName ? fail()

		@mesh =
			StrokeMesh.fromGeometry
				originalGeometry: originalGeometry
				layerOptions: [
					nStrokes: nStrokes
					strokeSize: 160
					strokeTexture: @resources().texture strokeTextureName
				]

		@mesh.addToGraphics @graphics()

		@body =
			@physics().addBody
				gameObject: @
				threeObject: @mesh._strokeLayers[0]._strokeSystem
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
