three = require 'three'
CameraController = require './CameraController'
FramerateTracker = require './FramerateTracker'
Game = require './Game'
StrokeMesh = require './StrokeMesh'

module.exports = class MeshGame extends Game
	initialObjects: ->
		cc =
			new CameraController
				distance: 25
		ft =
			new FramerateTracker '#frameRateNumber'

		knot =
			StrokeMesh.rainbowGeometry
				originalGeometry: new three.TorusKnotGeometry 10, 3, 100, 16
				nStrokes: 100000

		super.concat [ cc, ft, knot ]
