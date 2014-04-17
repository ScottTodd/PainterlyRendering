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
		textures: [ 'stroke' ]

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
				strokeLayerOptions: [
					nStrokes: 2000
					strokeSize: 500
					strokeTexture: @resources().texture 'stroke'
				,
					nStrokes: 30000
					strokeSize: 80
					strokeTexture: @resources().texture 'stroke'
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
				strokeLayerOptions: [
					nStrokes: 100000
					strokeSize: 160
					strokeTexture: @resources().texture 'stroke'
				]
				mass: 1

		super.concat [ cc, ft, @ground, @bunny ]

	otherSetup: ->
		@graphics().camera().position.set 0, 20, 20
		@physics().setGravity new three.Vector3 0, -9.8, 0
		@physics().addMaterialContact 'bunny', 'ground', 0, 1

		@bunny.listenForCollide (who) =>
			console.log 'collide!'
			check who == @ground
