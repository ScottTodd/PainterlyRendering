CameraController = require '../CameraController'
FramerateTracker = require '../FramerateTracker'
Game = require '../Game'
ParametersController = require '../ui/ParametersController'

module.exports = class ParametersGame extends Game
	allResources: ->
		models: [ ]
		textures: [ 'stroke1' ]

	initialObjects: ->
		cc =
			new CameraController
		ft =
			new FramerateTracker '#frameRateNumber'
		pc =
			new ParametersController 'parameters'

		three = require 'three'
		SimpleStrokeMeshObject = require '../SimpleStrokeMeshObject'
		s2 =
			new SimpleStrokeMeshObject (new three.Vector3 0, 0, 0),
				geometry: new three.SphereGeometry 2, 32, 32
				strokeTexture: @resources().texture 'stroke1'
				colors: type: 'rainbow'
				layers: [
					nStrokes: 2000
					strokeSize: 160
				]

		super.concat [ cc, ft, pc ]
