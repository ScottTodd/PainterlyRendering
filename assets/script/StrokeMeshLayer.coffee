fs = require 'fs'
$ = require 'jquery'
three = require 'three'
{ check } = require './check'
meshVerticesNormals = require './meshVerticesNormals'
{ read } = require './meta'

getOpt = (opts, name, defaultOpt) ->
	if opts[name]?
		opts[name]
	else if defaultOpt?
		defaultOpt()
	else
		throw new Error "Must specify #{name}"

module.exports = class StrokeMeshLayer

	###
	@param opts
	geometry: [three.Geometry]
	nStrokes: [Number]
	strokeSize: [Number]
	strokeTexture: [three.Texture]
	colors:
		type: 'rainbow'
		OR
		???
	###
	@of: (opts) ->
		geometry = getOpt opts, 'geometry'

		outOpts = { }

		outOpts.nStrokes = getOpt opts, 'nStrokes'
		outOpts.strokeSize = getOpt opts, 'strokeSize'
		outOpts.strokeTexture = getOpt opts, 'strokeTexture'

		colorsOpt = getOpt opts, 'colors'
		check colorsOpt.type == 'rainbow' # TODO: other color methods
		outOpts.colors =
			for _ in [0...opts.nStrokes]
				new three.Color 0xffffff * Math.random()

		[ outOpts.vertices, outOpts.normals ] =
			meshVerticesNormals (new three.Mesh geometry), outOpts.nStrokes

		new StrokeMeshLayer outOpts


	###
	@private
	Use a factory method instead!
	###
	constructor: (opts) ->
		{ nStrokes, strokeSize, vertices, normals, colors, strokeTexture } = opts

		check vertices.length == nStrokes, 'must have nStrokes vertices'
		check normals.length == nStrokes, 'must have nStrokes normals'
		check colors.length == nStrokes, 'must have nStrokes colors'

		uniforms =
			strokeTexture:
				type: 't'
				value: strokeTexture
			strokeSize:
				type: 'f'
				value: strokeSize
		$.extend uniforms,
			three.UniformsLib.lights

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

	addToParent: (parent) ->
		parent.add @_strokeSystem

