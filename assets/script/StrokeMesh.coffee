fs = require 'fs'
three = require 'three'
GameObject = require './GameObject'
{ check } =require './check'

module.exports = class StrokeMesh extends GameObject
	@rainbowSphere: (opts) ->
		nStrokes = opts.nStrokes ? 10
		radius = opts.radius ? 1
		center = opts.center ? new three.Vector3 0, 0, 0

		vertices = []
		normals = []

		for _ in [0...nStrokes]
			randCoord = ->
				Math.random() * 2 - 1
			randomNormal =
				new three.Vector3 randCoord(), randCoord(), randCoord()
			randomNormal.normalize()

			position = randomNormal.clone()
			position.multiplyScalar radius

			vertices.push position
			normals.push randomNormal

		colors =
			for _ in [0...nStrokes]
				new three.Color 0xffffff * Math.random()

		originalGeometry =
			new three.SphereGeometry radius, 32, 32
		originalMaterial =
			new three.MeshBasicMaterial
		originalMesh =
			new three.Mesh originalGeometry, originalMaterial

		new StrokeMesh
			nStrokes: nStrokes
			vertices: vertices
			normals: normals
			colors: colors
			center: center
			originalMesh: originalMesh


	###
	@private
	Use a factory method instead!
	###
	constructor: (opts) ->
		get = (name, defaultOpt) ->
			if opts[name]?
				opts[name]
			else if defaultOpt?
				defaultOpt()
			else
				throw new Error "Must specify #{name}"

		nStrokes = get 'nStrokes'
		vertices = get 'vertices'
		normals = get 'normals'
		colors = get 'colors'
		center = get 'center'
		@originalMesh = get 'originalMesh'
		texture = get 'strokeTexture', ->
			three.ImageUtils.loadTexture 'texture/stroke.png'

		check vertices.length == nStrokes
		check normals.length == nStrokes
		check colors.length == nStrokes

		uniforms =
			strokeTexture:
				type: 't'
				value: texture

		attributes =
			strokeVertexNormal:
				type: 'v3'
				value: normals

		@material =
			new three.ShaderMaterial
				uniforms: uniforms
				attributes: attributes

				vertexShader: fs.readFileSync __dirname + '/../shader/stroke.vs.glsl'
				fragmentShader: fs.readFileSync __dirname + '/../shader/stroke.fs.glsl'

				transparent: yes
				depthWrite: no

				vertexColors: yes

				# blended = src * srcAlpha + dest * (1 - srcAlpha)
				# In other words, fill in anything not already filled in
				#blending: three.CustomBlending
				#blendSrc: three.SrcAlphaFactor
				#blendDst: three.OneMinusSrcAlphaFactor
				#blendEquation: three.AddEquation
				#transparent: yes
				#depthWrite: no

		@strokeGeometry =
			new three.Geometry

		@strokeGeometry.vertices = vertices
		@strokeGeometry.computeBoundingBox()
		@strokeGeometry.computeBoundingSphere()

		@strokeGeometry.colors = colors
		@strokeGeometry.colorsNeedUpdate = yes

		@strokeSystem =
			new three.ParticleSystem @strokeGeometry, @material
		#@strokeSystem.frustomCulled = yes
		#@strokeSystem.sortParticles = yes

		@center = center
		@strokeSystem.position = @center
		@originalMesh.position = @center


	addToGraphics: (graphics) ->
		graphics.originalMeshesParent.add @originalMesh
		graphics.strokeMeshesParent.add @strokeSystem


