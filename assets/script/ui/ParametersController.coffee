$ = require 'jquery'
three = require 'three'
GameObject = require '../GameObject'
SimpleStrokeMeshObject = require '../SimpleStrokeMeshObject'
LayerController = require './LayerController'
LightController = require './LightController'
RadioSelector = require './RadioSelector'
Range = require './Range'

module.exports = class ParametersController extends GameObject
	constructor: (@_divName) ->
		null


	genBalls: (strokeMeshOpts) ->
		PhysicalObject = require '../PhysicalObject'
		cannon = require 'cannon'

		@boxSize =
			50
		ballSize =
			4

		@walls =
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
		@walls.push ground

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
			@walls.push wall

		numBalls =
			10
		spawnAreaPercentage =
			0.9
		ballMaxSpeed =
			20

		@balls =
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
					strokeMeshOptions: strokeMeshOpts
					init: ->
						@quaternion().setFromAxisAngle \
							(new cannon.Vec3 1, 0, 0),
							- Math.PI / 2
			@balls.push ball

		@walls.concat @balls


	start: ->
		meshOptionsDiv =
			$ "<div class='meshOptions'/>"
		@_geometry =
			new RadioSelector
				name: 'Geometry'
				options: [
					'sphere', 'bunny', 'teapot', 'quad', 'bounce'
				]
				start: 'sphere'
		@_borderSize =
			new Range
				name: 'Border'
				min: 0
				max: 0.25
				start: 0.1
		@_geometry.change().add =>
			@regenerate()
		@_borderSize.change().add =>
			@regenerate()

		meshOptionsDiv.append \
			@_geometry.div(),
			($ "<div class='rangeGroup'/>").append @_borderSize.div()

		@_layers =
			for idx in [0...3]
				@emit new LayerController @, idx

		@_ambient =
			new Range
				name: 'Ambient'
				min: 0
				max: 1
				start: 0.2

		@_lights =
			for idx in [0...3]
				@emit new LightController @, idx

		lightsDiv =
			$ "<div/>"
		lightsDiv.append ($ "<div class='rangeGroup'/>").append @_ambient.div()
		@_ambient.change().add =>
			lum = @_ambient.get()
			col = new three.Color
			col.setHSL 0, 0, lum
			@graphics().setAmbient col
		for light in @_lights
			lightsDiv.append light.div()

		@regenerate()

		($ 'document').ready =>
			div = $ "##{@_divName}"
			div.addClass 'parametersController'
			div.empty()
			#div.append (($ "<div class='controlTitle' name='mesh'/>").text "Mesh")
			div.append meshOptionsDiv
			div.append ($ "<div class='controlTitle' name='layers'/>").text "Layers…"
			for layer in @_layers
				div.append layer.div()
			div.append ($ "<div class='controlTitle' name='lights'/>").text "Lights…"
			div.append lightsDiv


	regenerate: ->
		if @_obj?
			@_obj.die()
		if @walls?
			for wall in @walls
				wall.die()
		if @balls?
			for ball in@balls
				ball.die()

		opts =
			borderSize: @_borderSize.get()
			layers: layer.opts() for layer in @_layers when layer.on()

		if @_geometry.get() == 'bounce'
			x = @genBalls opts
			for b in x
				@emit b
		else
			opts.geometry =
				@resources().geometry @_geometry.get()

			@_obj =
				new SimpleStrokeMeshObject (new three.Vector3 0, 0, 0), opts

			@emit @_obj

