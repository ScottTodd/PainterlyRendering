three = require 'three'
CameraController = require './CameraController'
FramerateTracker = require './FramerateTracker'
Game = require './Game'
StrokeMesh = require './StrokeMesh'

module.exports = class SpheresGame extends Game
	allResources: ->
		models: [ ]
		textures: [ 'stroke' ]

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
				strokeTexture: @resources.texture 'stroke'

		s2 =
			StrokeMesh.rainbowSphere
				center: (new three.Vector3 0.9, 0, -6)
				radius: 2
				nStrokes: 2000
				strokeTexture: @resources.texture 'stroke'
		s3 =
			StrokeMesh.rainbowSphere
				center: (new three.Vector3 1.4, 0, 0)
				radius: 1
				nStrokes: 2000
				strokeTexture: @resources.texture 'stroke'

		super.concat [ cc, ft, s1, s2, s3 ]
