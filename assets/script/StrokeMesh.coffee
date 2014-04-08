fs = require 'fs'
three = require 'three'

module.exports = class StrokeMesh
	constructor: (center, radius) ->
		@nStrokes =
			4000

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
			strokeVertexNormal:
				type: 'v3'
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
			center

		@circleRadius =
			radius

		@randCoord = ->
			Math.random() * 2 - 1

		for idx in [0...@nStrokes]
			randomNormal =
				new three.Vector3 @randCoord(), @randCoord(), @randCoord()
			randomNormal.normalize()

			offset = randomNormal.clone()
			offset.multiplyScalar @circleRadius

			position = offset.clone()
			position.add @circleCenter

			@strokeGeometry.vertices.push position
			attributes.strokeVertexNormal.value.push randomNormal

		@strokeSystem =
			new three.ParticleSystem @strokeGeometry, @material

		@strokeSystem.frustomCulled = yes
		@strokeSystem.sortParticles = yes

