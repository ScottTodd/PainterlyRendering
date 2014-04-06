fs = require 'fs'
three = require 'three'

module.exports = class StrokeMesh
	constructor: (scene) ->
		@nStrokes =
			1000

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

		for idx in [0...@nStrokes]
			p = ->
				Math.random() * 20 - 10

			@strokeGeometry.vertices.push new three.Vector3 p(), p(), p()

		@strokeSystem =
			new three.ParticleSystem @strokeGeometry, @material

		@strokeSystem.frustomCulled = yes
		@strokeSystem.sortParticles = yes

		scene.add @strokeSystem

