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
				strokeTextureName: 'stroke'
				nStrokes: 50000
				init: ->
					@quaternion().setFromAxisAngle \
						(new cannon.Vec3 1, 0, 0),
						- Math.PI / 2

		@bunny =
			new PhysicalObject
				center: new three.Vector3 0, 10, 0
				modelName: 'bunny'
				materialName: 'bunny'
				strokeTextureName: 'stroke'
				nStrokes: 100000
				mass: 1

		super.concat [ cc, ft, @ground, @bunny ]

	otherSetup: ->
		@graphics().camera().position.set 0, 20, 20
		@physics().setGravity new three.Vector3 0, -9.8, 0
		@physics().addMaterialContact 'bunny', 'ground', 0, 1

		@bunny.listenForCollide (who) =>
			console.log 'collide!'
			check who == @ground
