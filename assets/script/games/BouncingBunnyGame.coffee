cannon = require 'cannon'
three = require 'three'
CameraController = require '../CameraController'
{ check } = require '../check'
FramerateTracker = require '../FramerateTracker'
Game = require '../Game'
PhysicalObject = require '../PhysicalObject'

module.exports = class BouncingBunnyGame extends Game
	allResources: ->
		models: [ 'bunny' ]
		textures: [ 'stroke1' ]

	initialObjects: ->
		cc =
			new CameraController
				distance: 25

		ft =
			new FramerateTracker '#frameRateNumber'

		@ground =
			new PhysicalObject
				center: new three.Vector3 0, -10, 0
				model: new three.PlaneGeometry 50, 50
				materialName: 'ground'
				strokeMeshOptions:
					strokeTexture: @resources().texture 'stroke1'
					colors: type: 'rainbow'
					layers: [
							nStrokes: 2000
							strokeSize: 1.25
						,
							nStrokes: 30000
							strokeSize: 0.2
					]
				init: ->
					@quaternion().setFromAxisAngle \
						(new cannon.Vec3 1, 0, 0),
						- Math.PI / 2

		@bunny =
			new PhysicalObject
				center: new three.Vector3 0, 10, 0
				modelName: 'bunny'
				materialName: 'bunny'
				mass: 1
				strokeMeshOptions:
					strokeTexture: @resources().texture 'stroke1'
					colors: type: 'rainbow'
					layers: [
						nStrokes: 100000
						strokeSize: 0.4
					]

		super.concat [ cc, ft, @ground, @bunny ]

	otherSetup: ->
		@graphics().camera().position.set 0, 20, 20
		@physics().setGravity new three.Vector3 0, -9.8, 0
		@physics().addMaterialContact 'bunny', 'ground', 0, 1

		@bunny.listenForCollide (who) =>
			console.log 'collide!'
			check who == @ground
