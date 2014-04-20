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
				geometry: new three.SphereGeometry 2, 32, 32
				strokeTexture: @resources().texture 'stroke'
				layers: [
						nStrokes: 100
						strokeSize: 200
						colors:
							type: 'randomHSL'
							hue: 0.25
							sat: [0.25, 0.75]
							lum: 0.5
					,
						nStrokes: 2000
						strokeSize: 100
						colors:
							type: 'randomHSL'
							hue: 0.5
							sat: [0.5, 1]
							lum: 0.5
				]

		s2 =
			new SimpleStrokeMeshObject (new three.Vector3 0.9, 0, -6),
				geometry: new three.SphereGeometry 2, 32, 32
				strokeTexture: @resources().texture 'stroke'
				colors: type: 'rainbow'
				layers: [
					nStrokes: 2000
					strokeSize: 160
				]

		s3 =
			new SimpleStrokeMeshObject (new three.Vector3 1.4, 0, 0),
				geometry: new three.SphereGeometry 1, 32, 32
				strokeTexture: @resources().texture 'stroke'
				colors: type: 'rainbow'
				layers: [
					nStrokes: 2000
					strokeSize: 160
				]

		super.concat [ cc, ft, s1 ]#, s2, s3 ]
