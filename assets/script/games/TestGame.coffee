three = require 'three'
CameraController = require '../CameraController'
FramerateTracker = require '../FramerateTracker'
Game = require '../Game'
SimpleStrokeMeshObject = require '../SimpleStrokeMeshObject'

module.exports = class TestGame extends Game
	allResources: ->
		models: [ ]
		textures: [ 'arrow']

	initialObjects: ->
		cc =
			new CameraController

		ft =
			new FramerateTracker '#frameRateNumber'

		sTest =
			new SimpleStrokeMeshObject (new three.Vector3 0, 0, 0),
				geometry: new three.SphereGeometry 2, 32, 32
				strokeTexture: @resources().texture 'arrow'
				layers: [
					nStrokes: 200
					strokeSize: 0.3
					colors:
						type: 'randomHSL'
						hue: 0
						sat: [0, 1]
						lum: 0.5
				]

		super.concat [ cc, ft, sTest ]
