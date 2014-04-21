three = require 'three'
CameraController = require '../CameraController'
FramerateTracker = require '../FramerateTracker'
Game = require '../Game'
SimpleStrokeMeshObject = require '../SimpleStrokeMeshObject'
StrokeMeshLayer = require '../StrokeMeshLayer'
StrokeMesh = require '../StrokeMesh'
TexturedObject = require '../TexturedObject'

module.exports = class TextureGame extends Game
	allResources: ->
		models: [ 'bunny', 'quad' ]
		textures: [ 'stroke', 'white', 'The_Scream', 'easy_colors' ]

	initialObjects: ->
		cc =
			new CameraController
				distance: 25
		ft =
			new FramerateTracker '#frameRateNumber'

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
				strokeTexture: @resources().texture 'stroke'
				layers: [
					nStrokes: 500
					strokeSize: 380
				,
					nStrokes: 3000
					strokeSize: 160
				,
					nStrokes: 10000
					strokeSize: 30

				]


		super.concat [ cc, ft, quad ]
