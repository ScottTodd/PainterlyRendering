$ = require 'jquery'
three = require 'three'
CameraController = require '../CameraController'
FramerateTracker = require '../FramerateTracker'
Game = require '../Game'
ParametersController = require '../ParametersController'
SimpleStrokeMeshObject = require '../SimpleStrokeMeshObject'

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
						nStrokes: 1000
						strokeSize: 175
						colors:
							type: 'randomHSL'
							hue: 0.5
							sat: [0.25, 0.75]
							lum: 0.4
					,
						nStrokes: 1250
						strokeSize: 125
						specularMin: 0
						specularFadeIn: 0.6
						colors:
							type: 'randomHSL'
							hue: 0.6
							sat: [0.5, 0.75]
							lum: 0.45
					,
						nStrokes: 1500
						strokeSize: 75
						specularMin: 0.6
						specularFadeIn: 0.4
						colors:
							type: 'randomHSL'
							hue: 0.65
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

		pc =
			new ParametersController 'parameters'

		super.concat [ cc, ft, s1, pc ]#, s2, s3 ]
