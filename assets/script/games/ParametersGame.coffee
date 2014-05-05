CameraController = require '../CameraController'
FramerateTracker = require '../FramerateTracker'
Game = require '../Game'
ScreenShooter = require '../ScreenShooter'
ParametersController = require '../ui/ParametersController'

module.exports = class ParametersGame extends Game
	allResources: ->
		models: [ 'bunny', 'lamp', 'teapot', 'quad' ]
		textures: [
			# Object textures
			'4colors', 'scream', 'sirius-1-10', 'sirius-2-17', 'sirius-2-19',
			'raytracing' # TODO: even more!

			# Stroke textures
			'stroke1', 'stroke2', 'stroke3', 'stroke4',
			'stroke5', 'noise1', 'noise2', 'circle',
			'triangle', 'square', 'stick', 'grid'
		]

	initialObjects: ->
		cc =
			new CameraController
		ft =
			new FramerateTracker '#frameRateNumber'
		pc =
			new ParametersController 'parameters'
		ss =
			new ScreenShooter '#screenShotButton'

		super.concat [ cc, ft, pc, ss ]


	otherSetup: ->
		three = require 'three'
		#@graphics().camera().position.set 0, 0, @boxSize / 2
		@physics().setGravity new three.Vector3 0, -9.8, 0
		@physics().addMaterialContact 'ball', 'wall', 0, 1
		@physics().addMaterialContact 'ball', 'ball', 0, 1
