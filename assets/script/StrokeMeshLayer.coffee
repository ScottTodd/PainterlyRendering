fs = require 'fs'
$ = require 'jquery'
three = require 'three'
{ check } = require './check'
GameObject = require './GameObject'
meshVerticesNormals = require './meshVerticesNormals'
{ read } = require './meta'

module.exports = class StrokeMeshLayer extends GameObject
	@rainbowSphere: (opts) ->
		opts.nStrokes ?= 10
		opts.radius ?= 1
		opts.strokeSize ?= 160

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

		new StrokeMeshLayer opts

	###
	opts:
	nStrokes
	originalGeometry
	strokeTexture
	###
	@rainbowGeometry: (opts) ->
		opts.nStrokes ?= 10
		opts.strokeSize ?= 160

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

		new StrokeMeshLayer opts

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
		strokeSize = get 'strokeSize'
		vertices = get 'vertices'
		normals = get 'normals'
		colors = get 'colors'
		@_originalMesh = get 'originalMesh'
		texture = get 'strokeTexture'

		check vertices.length == nStrokes, 'must have nStrokes vertices'
		check normals.length == nStrokes, 'must have nStrokes normals'
		check colors.length == nStrokes, 'must have nStrokes colors'

		uniforms =
			strokeTexture:
				type: 't'
				value: texture
			strokeSize:
				type: 'f'
				value: strokeSize
		$.extend uniforms,
			three.UniformsLib["lights"]

		attributes =
			strokeVertexNormal:
				type: 'v3'
				value: normals

		@_material =
			new three.ShaderMaterial
				uniforms: uniforms
				attributes: attributes

				vertexShader: fs.readFileSync __dirname + '/../shader/stroke.vs.glsl'
				fragmentShader: fs.readFileSync __dirname + '/../shader/stroke.fs.glsl'

				transparent: yes
				depthWrite: no

				vertexColors: yes

				lights: yes

				# blended = src * srcAlpha + dest * (1 - srcAlpha)
				# In other words, fill in anything not already filled in
				#blending: three.CustomBlending
				#blendSrc: three.SrcAlphaFactor
				#blendDst: three.OneMinusSrcAlphaFactor
				#blendEquation: three.AddEquation
				#transparent: yes
				#depthWrite: no

		@_strokeGeometry =
			new three.Geometry

		@_strokeGeometry.vertices = vertices
		@_strokeGeometry.computeBoundingBox()
		@_strokeGeometry.computeBoundingSphere()

		@_strokeGeometry.colors = colors
		@_strokeGeometry.colorsNeedUpdate = yes

		@_strokeSystem =
			new three.ParticleSystem @_strokeGeometry, @_material

	read @, 'strokeSystem'

	addToGraphics: (graphics) ->
		graphics.originalMeshesParent.add @_originalMesh
		graphics.strokeMeshesParent.add @_strokeSystem

	setPosition: (pos) ->
		@_strokeSystem.position.copy pos
		@_originalMesh.position.copy pos
