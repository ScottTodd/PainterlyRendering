three = require 'three'
CameraController = require '../CameraController'
FramerateTracker = require '../FramerateTracker'
Game = require '../Game'
ScreenShooter = require '../ScreenShooter'
SimpleStrokeMeshObject = require '../SimpleStrokeMeshObject'
StrokeMeshLayer = require '../StrokeMeshLayer'
StrokeMesh = require '../StrokeMesh'
TexturedObject = require '../TexturedObject'

module.exports = class TextureGame extends Game
	allResources: ->
		models: [ 'bunny', 'quad' ]
		textures: [ 'stroke1', 'white', 'The_Scream', 'easy_colors' ]

	initialObjects: ->
		cc =
			new CameraController
				distance: 25
		ft =
			new FramerateTracker '#frameRateNumber'
		ss =
			new ScreenShooter '#screenShotButton'

		testQuad =
			new TexturedObject (new three.Vector3 0, 0, 0),
				geometry: @resources().geometry 'quad'
				texture: @resources().texture 'The_Scream'

		quad =
			new SimpleStrokeMeshObject (new three.Vector3 0, 0, 0),
				geometry: @resources().geometry 'quad'
				objectTexture: @resources().texture 'The_Scream'
				colors:
					type: 'randomHSL'
					hue: 0.65
					sat: 0.0
					lum: 1.0
				strokeTexture: @resources().texture 'stroke1'
				specularIntensity: 0
				layers: [
					nStrokes: 600
					strokeSize: 0.9
				,
					nStrokes: 1000
					strokeSize: 0.5
				,
					nStrokes: 3000
					strokeSize: 0.15

				]


		super.concat [ cc, ft, ss, quad ]
