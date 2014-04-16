three = require 'three'
CameraController = require '../CameraController'
FramerateTracker = require '../FramerateTracker'
Game = require '../Game'
SimpleStrokeMeshObject = require '../SimpleStrokeMeshObject'
StrokeMeshLayer = require '../StrokeMeshLayer'
StrokeMesh = require '../StrokeMesh'

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
			new SimpleStrokeMeshObject (new three.Vector3 0, 0, 0),
				StrokeMesh.fromLayers
					strokeLayers: [
						StrokeMeshLayer.rainbowSphere
							radius: 2
							nStrokes: 120
							strokeSize: 400
							strokeTexture: @resources().texture 'stroke'
						StrokeMeshLayer.rainbowSphere
							radius: 2
							nStrokes: 20000
							strokeSize: 100
							strokeTexture: @resources().texture 'stroke'
					]

		s2 =
			new SimpleStrokeMeshObject (new three.Vector3 0.9, 0, -6),
				StrokeMesh.fromLayers
					strokeLayers: [
						StrokeMeshLayer.rainbowSphere
							radius: 2
							nStrokes: 2000
							strokeTexture: @resources().texture 'stroke'
					]

		s3 =
			new SimpleStrokeMeshObject (new three.Vector3 1.4, 0, 0),
				StrokeMesh.fromLayers
					strokeLayers: [
						StrokeMeshLayer.rainbowSphere
							radius: 1
							nStrokes: 2000
							strokeTexture: @resources().texture 'stroke'
					]

		super.concat [ cc, ft, s1, s2, s3 ]
