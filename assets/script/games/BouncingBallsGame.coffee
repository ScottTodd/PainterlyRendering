cannon = require 'cannon'
three = require 'three'
CameraController = require '../CameraController'
{ check } = require '../check'
FramerateTracker = require '../FramerateTracker'
Game = require '../Game'
PhysicalObject = require '../PhysicalObject'

module.exports = class BouncingBallsGame extends Game
	allResources: ->
		models: [ ]
		textures: [ 'stroke1' ]

	initialObjects: ->
		cc =
			new CameraController
				distance: 25

		ft =
			new FramerateTracker '#frameRateNumber'

		@boxSize =
			50
		ballSize =
			4

		walls =
			[]

		ground =
			new PhysicalObject
				center: new three.Vector3 0, -@boxSize/2, 0
				model: new three.PlaneGeometry @boxSize, @boxSize
				materialName: 'wall'
				strokeMeshOptions:
					strokeTexture: @resources().texture 'stroke1'
					colors:
						type: 'randomHSL'
						hue: [0.08, 0.12]
						sat: [0.40, 0.80]
						lum: [0.20, 0.40]
					specularIntensity: 0.2
					specularPower: 4
					layers: [
							nStrokes: 4000
							strokeSize: 1.75
						,
							nStrokes: 30000
							strokeSize: 0.8
					]
				init: ->
					@quaternion().setFromAxisAngle \
						(new cannon.Vec3 1, 0, 0),
						- Math.PI / 2
		walls.push ground

		wallProperties = [
			center: new three.Vector3 -@boxSize/2, 0, 0
			rotationAxis: new cannon.Vec3 0, 1, 0
			rotationAngle: Math.PI / 2
		,
			center: new three.Vector3 @boxSize/2, 0, 0
			rotationAxis: new cannon.Vec3 0, 1, 0
			rotationAngle: - Math.PI / 2
		,
			center: new three.Vector3 0, 0, -@boxSize/2
			rotationAxis: new cannon.Vec3 0, 1, 0
			rotationAngle: 0
		,
			center: new three.Vector3 0, 0, @boxSize/2
			rotationAxis: new cannon.Vec3 0, 1, 0
			rotationAngle: Math.PI
		,
			center: new three.Vector3 0, @boxSize/2, 0
			rotationAxis: new cannon.Vec3 1, 0, 0
			rotationAngle: Math.PI / 2
		]

		wallProperties.forEach (wallProperty) =>
			{ center, rotationAxis, rotationAngle } = wallProperty

			wall =
				new PhysicalObject
					center: center
					model: new three.PlaneGeometry @boxSize, @boxSize
					materialName: 'wall'
					strokeMeshOptions:
						strokeTexture: @resources().texture 'stroke1'
						colors:
							type: 'randomHSL'
							hue: [0.08, 0.12]
							sat: [0.05, 0.25]
							lum: [0.20, 0.40]
						specularIntensity: 0.8
						specularPower: 4
						layers: [
								nStrokes: 4000
								strokeSize: 1.75
							,
								nStrokes: 30000
								strokeSize: 0.8
						]
					init: ->
						@quaternion().setFromAxisAngle \
							rotationAxis, rotationAngle
			walls.push wall

		numBalls =
			10
		spawnAreaPercentage =
			0.9
		ballMaxSpeed =
			20

		balls =
			[]

		randomPosition = =>
			(Math.random() - 0.5) * @boxSize * spawnAreaPercentage

		randomVelocityComponent = ->
			(Math.random() - 0.5) * 2

		for _ in [0...numBalls]
			pX =
				randomPosition()
			pY =
				randomPosition()
			pZ =
				randomPosition()
			center =
				new three.Vector3 pX, pY, pZ

			vX =
				randomVelocityComponent()
			vY =
				randomVelocityComponent()
			vZ =
				randomVelocityComponent()
			velocity =
				new three.Vector3 vX, vY, vZ
			velocity.normalize()
			velocity.multiplyScalar Math.random() * ballMaxSpeed

			ball =
				new PhysicalObject
					center: center
					velocity: velocity
					model: new three.SphereGeometry ballSize, 48, 48
					materialName: 'ball'
					mass: 1
					strokeMeshOptions:
						strokeTexture: @resources().texture 'stroke1'
						colors:
							type: 'randomHSL'
							hue: [0.05, 0.25]
							sat: [0.40, 0.80]
							lum: [0.40, 0.80]
						specularIntensity: 1
						specularPower: 4
						layers: [
								nStrokes: 4000
								strokeSize: 0.5
						]
					init: ->
						@quaternion().setFromAxisAngle \
							(new cannon.Vec3 1, 0, 0),
							- Math.PI / 2
			balls.push ball

		super.concat [ cc, ft ], walls, balls

	otherSetup: ->
		@graphics().camera().position.set 0, 0, @boxSize / 2
		@physics().setGravity new three.Vector3 0, -9.8, 0
		@physics().addMaterialContact 'ball', 'wall', 0, 1
		@physics().addMaterialContact 'ball', 'ball', 0, 1
