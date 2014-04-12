three = require 'three'
CameraController = require '../CameraController'
FramerateTracker = require '../FramerateTracker'
Game = require '../Game'
SimpleStrokeMeshObject = require '../SimpleStrokeMeshObject'
StrokeMesh = require '../StrokeMesh'

module.exports = class MeshGame extends Game
	allResources: ->
		models: [ 'bunny' ]
		textures: [ 'stroke' ]

	initialObjects: ->
		cc =
			new CameraController
				distance: 25
		ft =
			new FramerateTracker '#frameRateNumber'

		knot =
			new SimpleStrokeMeshObject (new three.Vector3 0, 0, 0),
				StrokeMesh.rainbowGeometry
					originalGeometry: new three.TorusKnotGeometry 10, 3, 100, 16
					nStrokes: 100000
					strokeTexture: @resources().texture 'stroke'

		bunny =
			new SimpleStrokeMeshObject (new three.Vector3 0, 0, 0),
				StrokeMesh.rainbowGeometry
					originalGeometry: @resources().geometry 'bunny'
					nStrokes: 100000
					strokeTexture: @resources().texture 'stroke'

		super.concat [ cc, ft, bunny ]
