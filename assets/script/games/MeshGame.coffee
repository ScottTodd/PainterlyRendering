three = require 'three'
CameraController = require '../CameraController'
FramerateTracker = require '../FramerateTracker'
Game = require '../Game'
SimpleStrokeMeshObject = require '../SimpleStrokeMeshObject'
StrokeMeshLayer = require '../StrokeMeshLayer'
ScreenShooter = require '../ScreenShooter'
StrokeMesh = require '../StrokeMesh'
Light = require '../Light'

module.exports = class MeshGame extends Game
	allResources: ->
		models: [ 'bunny', 'teapot' ]
		textures: [
			'arrow', 'grid', 'stick', 'noise2',
			'stroke1', 'stroke2', 'stroke3', 'stroke4', 'stroke5'
		]

	initialObjects: ->
		cc =
			new CameraController
				distance: 20
		ft =
			new FramerateTracker '#frameRateNumber'

		ss =
			new ScreenShooter '#screenShotButton'

		testSphere =
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

		sphere =
			new SimpleStrokeMeshObject (new three.Vector3 0, 0, 0),
				geometry: new three.SphereGeometry 2, 32, 32
				strokeTexture: @resources().texture 'stroke1'
				layers: [
						nStrokes: 1000
						strokeSize: 0.5
						colors:
							type: 'randomHSL'
							hue: 0.5
							sat: [0.25, 0.75]
							lum: 0.4
					,
						nStrokes: 1250
						strokeSize: 0.3
						specularMin: 0
						specularFadeIn: 0.6
						colors:
							type: 'randomHSL'
							hue: 0.6
							sat: [0.5, 0.75]
							lum: 0.45
					,
						nStrokes: 1500
						strokeSize: 0.15
						specularMin: 0.6
						specularFadeIn: 0.4
						colors:
							type: 'randomHSL'
							hue: 0.65
							sat: [0.5, 1]
							lum: 0.5
				]

		knot =
			new SimpleStrokeMeshObject (new three.Vector3 0, 0, 0),
				geometry: new three.TorusKnotGeometry 10, 3, 100, 16
				colors:
					type: 'randomHSL'
					hue: 0.75
					sat: [ 0, 0.5 ]
					lum: [ 0, 0.5 ]
				layers: [
					nStrokes: 20000
					strokeSize: 1
					strokeTexture: @resources().texture 'stroke1'
				]

		bunny =
			new SimpleStrokeMeshObject (new three.Vector3 0, 0, 0),
				geometry: @resources().geometry 'bunny'
				borderSize: 0.33
				specularAmount: 2
				specularPow: 4
				layers: [
						nStrokes: 1400
						strokeSize: 0.8
						strokeTexture: @resources().texture 'stroke1'
						colors:
							type: 'randomHSL'
							hue: [ 0.14, 0.18 ]
							sat: [ 0.1, 0.7 ]
							lum: 0.4
						specularAmount: 0
					,
						nStrokes: 1800
						strokeSize: 0.6
						strokeTexture: @resources().texture 'stroke4'
						specularMin: 0
						specularFadeIn: 0.25
						colors:
							type: 'randomHSL'
							hue: [ 0.18, 0.28 ]
							sat: [ 0.6, 1.2 ]
							lum: [ 0.2, 0.3 ]
					,
						nStrokes: 4800
						strokeSize: 0.2
						strokeTexture: @resources().texture 'stroke5'
						specularMin: 0.7
						specularFadeIn: 1
						colors:
							type: 'randomHSL'
							hue: [ 0.18, 0.28 ]
							sat: [ 0.5, 1 ]
							lum: [ 0.25, 0.5 ]
				]

		americanTeapot =
			new SimpleStrokeMeshObject (new three.Vector3 0, -1.5, 0),
				geometry: @resources().geometry 'teapot'
				borderSize: 0.2
				specularAmount: 2
				specularPow: 4
				strokeSize: 0.2
				strokeTexture: @resources().texture 'grid'
				layers: [
						nStrokes: 1600
						colors:
							type: 'randomHSL'
							hue: 0
							sat: 0.5
							lum: [ 0, 1 ]
					,
						nStrokes: 800
						colors:
							type: 'randomHSL'
							hue: 0.65
							sat: 0.5
							lum: [ 0, 1 ]
				]

		magmaBunny =
			new SimpleStrokeMeshObject (new three.Vector3 0, 0, 0),
				geometry: @resources().geometry 'bunny'
				specularAmount: 2
				specularPow: 4
				layers: [
						nStrokes: 1132
						strokeSize: 0.8
						strokeTexture: @resources().texture 'stroke2'
						colors:
							type: 'randomHSL'
							hue: 0
							sat: 0.5
							lum: 0.22
					,
						nStrokes: 1471
						strokeSize: 0.4
						strokeTexture: @resources().texture 'noise2'
						colors:
							type: 'randomHSL'
							hue: 0.02
							sat: 0.8
							lum: 0.34
					,
						nStrokes: 2000
						strokeSize: 0.22
						strokeTexture: @resources().texture 'noise2'
						colors:
							type: 'randomHSL'
							hue: [ 0.03, 0.15 ]
							sat: [ 0.68, 0.94 ]
							lum: 0.33
						specularMin: 0.95
						specularFadeIn: 0.63
				]

		layerBall =
			new SimpleStrokeMeshObject (new three.Vector3 0, 0, 0),
				geometry: new three.SphereGeometry 2, 32, 32
				borderSize: 0.35
				specularAmount: 2
				specularPow: 4
				layers: [
						nStrokes: 400
						strokeSize: 0.8
						strokeTexture: @resources().texture 'stroke1'
						colors:
							type: 'randomHSL'
							hue: 0
							sat: [ 0.5, 1 ]
							lum: 0.25
					,
						nStrokes: 800
						strokeSize: 0.4
						strokeTexture: @resources().texture 'grid'
						colors:
							type: 'randomHSL'
							hue: 0.95
							sat: [ 0.25, 0.75 ]
							lum: 0.25
						specularFadeIn: 1.51
					,
						nStrokes: 1600
						strokeSize: 0.2
						strokeTexture: @resources().texture 'stick'
						colors:
							type: 'randomHSL'
							hue: [ -0.22, 0.36 ]
							sat: [ 0.6, 1 ]
							lum: 0.25
						specularFadeIn: 4.17
				]

		l1 =
			new Light
				direction: new three.Vector3 1, 1, 1
				lum: 1
		l2 =
			new Light
				direction: new three.Vector3 -1, -1, -1
				lum: 0.5

		super.concat [ cc, ft, ss, l1, l2, magmaBunny ]
