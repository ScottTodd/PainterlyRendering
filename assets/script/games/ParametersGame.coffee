CameraController = require '../CameraController'
FramerateTracker = require '../FramerateTracker'
Game = require '../Game'
ScreenShooter = require '../ScreenShooter'
ParametersController = require '../ui/ParametersController'

module.exports = class ParametersGame extends Game
	allResources: ->
		models: [ 'sphere', 'bunny', 'lamp', 'teapot', 'quad' ]
		textures: [
			# Object textures
			'4colors', 'scream', 'raytrace', 'ice',
			'fire', 'water', 'grass', 'brick'

			# Stroke textures
			'stroke1', 'stroke2', 'stroke3', 'stroke4',
			'stroke5', 'noise1', 'noise2', 'circle',
			'triangle', 'square', 'stick', 'grid'
		]

	initialObjects: ->
		cc =
			new CameraController
				distance: 2
		ft =
			new FramerateTracker '#frameRateNumber'
		pc =
			new ParametersController 'parameters'
		ss =
			new ScreenShooter '#screenShotButton'

		super.concat [ cc, ft, pc, ss ]


	otherSetup: ->
		three = require 'three'
		@physics().setGravity new three.Vector3 0, -9.8, 0
		@physics().addMaterialContact 'ball', 'wall', 0, 1
		@physics().addMaterialContact 'ball', 'ball', 0, 1
