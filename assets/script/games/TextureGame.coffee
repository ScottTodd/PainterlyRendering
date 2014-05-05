three = require 'three'
CameraController = require '../CameraController'
FramerateTracker = require '../FramerateTracker'
Game = require '../Game'
ScreenShooter = require '../ScreenShooter'
SimpleStrokeMeshObject = require '../SimpleStrokeMeshObject'
TexturedObject = require '../TexturedObject'
Light = require '../Light'

module.exports = class TextureGame extends Game
	allResources: ->
		models: [ 'bunny', 'quad', 'sphere' ]
		textures: [ 'stroke1', 'white', 'scream', 'easy_colors' ]

	initialObjects: ->
		cc =
			new CameraController
				distance: 3
		ft =
			new FramerateTracker '#frameRateNumber'
		ss =
			new ScreenShooter '#screenShotButton'

		testQuad =
			new TexturedObject (new three.Vector3 0, 0, 0),
				geometry: @resources().geometry 'quad'
				texture: @resources().texture 'scream'

		quad =
			new SimpleStrokeMeshObject (new three.Vector3 0, 0, 0),
				geometry: @resources().geometry 'quad'
				objectTexture: @resources().texture 'scream'
				colors:
					type: 'randomHSL'
					hue: 0.65
					sat: 0.0
					lum: 1.0
				strokeTexture: @resources().texture 'stroke1'
				specularIntensity: 2.0
				layers: [
					nStrokes: 600
					strokeSize: 0.3
				,
					nStrokes: 1000
					strokeSize: 0.2
				,
					nStrokes: 3000
					strokeSize: 0.1
				]

		l1 =
			new Light
				direction: new three.Vector3 1, 1, 1
				lum: 0.5
		l2 =
			new Light
				direction: new three.Vector3 -1, -1, -1
				lum: 0.5

		super.concat [ cc, ft, ss, l1, l2, quad ]
