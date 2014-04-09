Game = require './Game'
three = require 'three'
CameraController = require './CameraController'
FramerateTracker = require './FramerateTracker'
StrokeMesh = require './StrokeMesh'

module.exports = class SpheresGame extends Game
	initialObjects: ->
		cc =
			new CameraController

		ft =
			new FramerateTracker '#frameRateNumber'

		s1 =
			StrokeMesh.rainbowSphere
				center: new three.Vector3 -0.9, 0, 0
				radius: 2
				nStrokes: 2000
		s2 =
			StrokeMesh.rainbowSphere
				center: (new three.Vector3 0.9, 0, -6)
				radius: 2
				nStrokes: 2000
		s3 =
			StrokeMesh.rainbowSphere
				center: (new three.Vector3 1.4, 0, 0)
				radius: 1
				nStrokes: 2000

		super.concat [ cc, ft, s1, s2, s3 ]