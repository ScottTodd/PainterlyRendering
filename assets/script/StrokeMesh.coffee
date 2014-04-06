fs = require 'fs'
three = require 'three'

module.exports = class StrokeMesh
	constructor: (scene) ->
		@nStrokes =
			10000

		uniforms =
			bright:
				type: 'f'
				value: 0
			strokeTexture:
				type: 't'
				value: three.ImageUtils.loadTexture 'texture/stroke.png'

		attributes =
			strokeColor:
				type: 'c'
				value: [ ]

		for idx in [0...@nStrokes]
			attributes.strokeColor.value.push new three.Color 0xffffff * Math.random()

		@material =
			new three.ShaderMaterial
				uniforms: uniforms
				attributes: attributes

				vertexShader: fs.readFileSync __dirname + '/../shader/stroke.vs.glsl'
				fragmentShader: fs.readFileSync __dirname + '/../shader/stroke.fs.glsl'

				transparent: yes
				blending: three.NormalBlending # Makes transparency work


		@strokeGeometry =
			new three.Geometry

		@circleCenter =
			new three.Vector3 0, 0, 0

		@circleRadius =
			2

		for idx in [0...@nStrokes]
			randCoord = ->
				Math.random() * 2 - 1

			position =
				new three.Vector3 randCoord(), randCoord(), randCoord()
			position.normalize()
			position.multiplyScalar @circleRadius
			position.add @circleCenter

			@strokeGeometry.vertices.push position

		@strokeSystem =
			new three.ParticleSystem @strokeGeometry, @material

		@strokeSystem.frustomCulled = yes
		@strokeSystem.sortParticles = yes

		scene.add @strokeSystem

