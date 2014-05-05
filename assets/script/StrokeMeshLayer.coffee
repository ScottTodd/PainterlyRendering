fs = require 'fs'
$ = require 'jquery'
three = require 'three'
{ check, type } = require './check'
meshVerticesNormalsUVs = require './meshVerticesNormalsUVs'
{ read } = require './meta'

getOpt = (opts, name, defaultOpt) ->
	if opts[name]?
		opts[name]
	else if defaultOpt?
		defaultOpt()
	else
		throw new Error "Must specify #{name}"


randomHSLs = (nStrokes, colorOpts) ->
	hue = getOpt colorOpts, 'hue'
	sat = getOpt colorOpts, 'sat'
	lum = getOpt colorOpts, 'lum'

	###
	If x is a Number, exactly x.
	Else, x is a range; choose a random member.
	###
	choose = (x) ->
		if Object(x) instanceof Number
			x
		else
			[ min, max ] = x
			type min, Number, max, Number
			Math.random() * (max - min) + min

	randomHSL = ->
		(new three.Color).setHSL (choose hue), (choose sat), (choose lum)

	for _ in [0...nStrokes]
		randomHSL()


module.exports = class StrokeMeshLayer
	###
	@param opts
	geometry: three.Geometry
	nStrokes: Number
	strokeSize: Number
	strokeTexture: three.Texture
	objectTexture: three.Texture
	colors:
		type: 'rainbow'
		OR
		type: 'randomHSL'
		hue: Number OR [Number, Number]
		sat: Number OR [Number, Number]
		lum: Number OR [Number, Number]
	###
	@of: (opts) ->
		geometry = getOpt opts, 'geometry'

		outOpts = { }

		outOpts.nStrokes = getOpt opts, 'nStrokes'
		outOpts.strokeSize = getOpt opts, 'strokeSize'
		outOpts.strokeTexture = getOpt opts, 'strokeTexture'
		outOpts.enableRotation =
			opts.enableRotation ? 1
		outOpts.curveFactor =
			opts.curveFactor ? 1.0
		outOpts.depthEpsilon =
			opts.depthEpsilon ? 1.0
		outOpts.objectTexture = getOpt opts, 'objectTexture', -> null

		colorsOpt = getOpt opts, 'colors'
		outOpts.colors =
			switch colorsOpt.type
				when 'rainbow'
					randomHSLs opts.nStrokes,
						hue: [0, 1]
						sat: 1
						lum: 0.5
				when 'randomHSL'
					randomHSLs opts.nStrokes, colorsOpt
				else
					fail()

		[ outOpts.vertices, outOpts.normals, outOpts.uvs, outOpts.hasUVs ] =
			meshVerticesNormalsUVs (new three.Mesh geometry), outOpts.nStrokes

		outOpts.specularIntensity =
			opts.specularIntensity ? 4
		outOpts.specularPower =
			opts.specularPower ? 4
		outOpts.specularMin =
			opts.specularMin ? 0
		outOpts.specularFadeIn =
			opts.specularFadeIn ? 0

		new StrokeMeshLayer outOpts


	###
	@private
	Use a factory method instead!
	###
	constructor: (opts) ->
		{ nStrokes, strokeSize, vertices, normals, uvs, hasUVs, colors,
		  strokeTexture, objectTexture, enableRotation, curveFactor, depthEpsilon,
		  specularMin, specularFadeIn, specularIntensity, specularPower } = opts

		check vertices.length == nStrokes, 'must have nStrokes vertices'
		check normals.length == nStrokes, 'must have nStrokes normals'
		check colors.length == nStrokes, 'must have nStrokes colors'

		@_strokeSize =
			strokeSize

		uniforms =
			strokeTexture:
				type: 't'
				value: strokeTexture
			objectTexture:
				type: 't'
				value: objectTexture
			useObjectTexture:
				type: 'i'
				value: hasUVs and objectTexture?
			strokeSize:
				type: 'f'
				value: 0 #strokeSize
			enableRotation:
				type: 'i'
				value: enableRotation
			curveFactor:
				type: 'f'
				value: curveFactor
			depthEpsilon:
				type: 'f'
				value: 0.6
			depthTexture:
				type: 't'
				value: null
			specularIntensity:
				type: 'f'
				value: specularIntensity
			specularPower:
				type: 'f'
				value: specularPower
			specularMin:
				type: 'f'
				value: specularMin
			specularFadeIn:
				type: 'f'
				value: specularFadeIn

		$.extend uniforms,
			three.UniformsLib.lights

		attributes =
			strokeVertexNormal:
				type: 'v3'
				value: normals
			strokeUV:
				type: 'v2'
				value: uvs

		material =
			new three.ShaderMaterial
				uniforms: uniforms
				attributes: attributes

				vertexShader: fs.readFileSync __dirname + '/../shader/stroke.vs.glsl'
				fragmentShader: fs.readFileSync __dirname + '/../shader/stroke.fs.glsl'

				transparent: yes
				depthWrite: no

				vertexColors: yes

				lights: yes

		strokeGeometry =
			new three.Geometry

		strokeGeometry.vertices = vertices
		strokeGeometry.computeBoundingBox()
		strokeGeometry.computeBoundingSphere()

		@_strokeSystem =
			new three.ParticleSystem strokeGeometry, material

		@setColors colors

	read @, 'strokeSystem'

	nStrokes: ->
		@_strokeSystem.geometry.vertices.length

	setupUsingGraphics: (graphics) ->
		graphics.divPromise().then =>
			@setUniform 'depthTexture', graphics.depthTexture()
			@setUniform 'strokeSize', @_strokeSize * graphics.size()
		.done()

	addToParent: (parent) ->
		parent.add @_strokeSystem

	setUniform: (name, value) ->
		@_strokeSystem.material.uniforms[name].value = value

	setColors: (colors) ->
		@_strokeSystem.geometry.colors = colors
		@_strokeSystem.geometry.colorsNeedUpdate = yes

