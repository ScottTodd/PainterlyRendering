fs = require 'fs'
$ = require 'jquery'
three = require 'three'
{ check } =require './check'
GameObject = require './GameObject'
meshVerticesNormals = require './meshVerticesNormals'

module.exports = class StrokeMesh extends GameObject
	@rainbowSphere: (opts) ->
		opts.nStrokes ?= 10
		opts.radius ?= 1

		vertices = []
		normals = []

		for _ in [0...opts.nStrokes]
			randCoord = ->
				Math.random() * 2 - 1
			randomNormal =
				new three.Vector3 randCoord(), randCoord(), randCoord()
			randomNormal.normalize()

			position = randomNormal.clone()
			position.multiplyScalar opts.radius

			vertices.push position
			normals.push randomNormal

		colors =
			for _ in [0...opts.nStrokes]
				new three.Color 0xffffff * Math.random()

		originalGeometry =
			new three.SphereGeometry opts.radius, 32, 32
		originalMaterial =
			new three.MeshBasicMaterial
		originalMesh =
			new three.Mesh originalGeometry, originalMaterial

		$.extend opts,
			vertices: vertices
			normals: normals
			colors: colors
			originalMesh: originalMesh

		new StrokeMesh opts

	###
	opts: nStrokes, originalGeometry, center, strokeTexture
	###
	@rainbowGeometry: (opts) ->
		opts.nStrokes ?= 10

		opts.originalMesh =
			new three.Mesh opts.originalGeometry, new three.MeshBasicMaterial

		[ vertices, normals ] = meshVerticesNormals opts.originalMesh, opts.nStrokes

		colors =
			for _ in [0...opts.nStrokes]
				new three.Color 0xffffff * Math.random()

		$.extend opts,
			vertices: vertices
			normals: normals
			colors: colors

		new StrokeMesh opts

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
		center = get 'center', -> new three.Vector3 0, 0, 0
		@originalMesh = get 'originalMesh'
		texture = get 'strokeTexture', ->
			three.ImageUtils.loadTexture 'texture/stroke.png'

		console.log nStrokes
		console.log vertices.length
		check vertices.length == nStrokes, 'must have nStrokes vertices'
		check normals.length == nStrokes, 'must have nStrokes normals'
		check colors.length == nStrokes, 'must have nStrokes colors'

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
		#@strokeSystem.sortParticles = yes

		@center = center
		@strokeSystem.position = @center
		@originalMesh.position = @center


	addToGraphics: (graphics) ->
		graphics.originalMeshesParent.add @originalMesh
		graphics.strokeMeshesParent.add @strokeSystem


