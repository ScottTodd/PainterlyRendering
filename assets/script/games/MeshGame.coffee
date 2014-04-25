three = require 'three'
CameraController = require '../CameraController'
FramerateTracker = require '../FramerateTracker'
Game = require '../Game'
SimpleStrokeMeshObject = require '../SimpleStrokeMeshObject'
StrokeMeshLayer = require '../StrokeMeshLayer'
StrokeMesh = require '../StrokeMesh'

module.exports = class MeshGame extends Game
	allResources: ->
		models: [ 'bunny' ]
		textures: [ 'stroke1' ]

	initialObjects: ->
		cc =
			new CameraController
				distance: 25
		ft =
			new FramerateTracker '#frameRateNumber'

		knot =
			new SimpleStrokeMeshObject (new three.Vector3 0, 0, 0),
				geometry: new three.TorusKnotGeometry 10, 3, 100, 16
				colors: type: 'rainbow'
				layers: [
					nStrokes: 100000
					strokeSize: 0.4
					strokeTexture: @resources().texture 'stroke1'
				]

		bunny =
			new SimpleStrokeMeshObject (new three.Vector3 0, 0, 0),
				geometry: @resources().geometry 'bunny'
				strokeTexture: @resources().texture 'stroke1'
				colors: type: 'rainbow'
				layers: [
					nStrokes: 2000
					strokeSize: 0.7
				,
					nStrokes: 10000
					strokeSize: 0.15
					strokeTexture: @resources().texture 'stroke1'
				]

		super.concat [ cc, ft, knot ]
