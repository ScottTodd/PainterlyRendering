q = require 'q'
three = require 'three'
{ check } = require './check'
{ read } = require './meta'
GameObject = require './GameObject'

module.exports = class Graphics extends GameObject
	constructor: ->
		try
			@renderer =
				new three.WebGLRenderer
					alpha: yes
					preserveDrawingBuffer: yes
		catch error
			alert 'Could not initialize WebGL!'
			throw error

		@_strokeMeshes =
			[]

		@_divDefer =
			q.defer()

	read @, 'camera', 'depthTexture', 'scene', 'strokeMeshes', 'width', 'height'

	imageDataURL: ->
		@renderer.domElement.toDataURL()

	size: ->
		# TODO: Is this the right formula to scale up with any screen?
		Math.min @_width, @_height

	divPromise: ->
		@_divDefer.promise

	bindToDiv: (div) ->
		@_width =
			div.width()
		@_height =
			div.height()

		@renderer.setSize @_width, @_height

		@resetAspect()

		div.append @renderer.domElement

		@_divDefer.resolve div.get 0

	resetAspect: ->
		check @_width?
		@_camera.aspect = @_width / @_height
		@_camera.updateProjectionMatrix()

		depthTextureOptions =
			magFilter: three.NearestFilter
			minFilter: three.NearestFilter
			wrapS: three.ClampToEdgeWrapping
			wrapT: three.ClampToEdgeWrapping
			type: three.FloatType

		@_depthTexture =
			new three.WebGLRenderTarget @_width, @_height, depthTextureOptions

	restart: ->
		@_scene =
			new three.Scene()

		@setupLights()

		@_camera =
			# aspect ratio will be changed in `bindToDiv`
			new three.PerspectiveCamera 75, 1, 0.1, 1000

		if @_width?
			@resetAspect()

		@_scene.add @_camera

	setAmbient: (color) ->
		@_ambientLight.color.copy color

	setupLights: ->
		@_ambientLight =
			new three.AmbientLight 0 # black
		@_scene.add @_ambientLight

		# Hack: light from all directions so no black box
		@addLight
			color: 0xffffff
			intensity: 0.01
			pos: new three.Vector3 -1, 0, 0
		@addLight
			color: 0xffffff
			intensity: 0.01
			pos: new three.Vector3 1, 0, 0
		@addLight
			color: 0xffffff
			intensity: 0.01
			pos: new three.Vector3 0, -1, 0
		@addLight
			color: 0xffffff
			intensity: 0.01
			pos: new three.Vector3 0, 1, 0
		@addLight
			color: 0xffffff
			intensity: 0.01
			pos: new three.Vector3 0, 0, -1
		@addLight
			color: 0xffffff
			intensity: 0.01
			pos: new three.Vector3 0, 0, 1

	addLight: (opts) ->
		color = opts.color
		intensity = opts.intensity
		pos = opts.pos

		light =
			new three.DirectionalLight color, intensity
		light.position.copy pos
		@_scene.add light

	setOriginalMeshesVisibility: (visibility) ->
		for strokeMesh in @_strokeMeshes
			strokeMesh.setOriginalMeshVisibility visibility

	setDepthMeshesVisibility: (visibility) ->
		for strokeMesh in @_strokeMeshes
			strokeMesh.setDepthMeshVisibility visibility

	setStrokeMeshesVisibility: (visibility) ->
		for strokeMesh in @_strokeMeshes
			strokeMesh.setStrokeMeshVisibility visibility

	draw: ->
		@setOriginalMeshesVisibility false
		@setDepthMeshesVisibility true
		@setStrokeMeshesVisibility false

		@renderer.render @_scene, @_camera, @_depthTexture, true

		@setOriginalMeshesVisibility true
		@setDepthMeshesVisibility false
		@setStrokeMeshesVisibility true

		@renderer.render @_scene, @_camera
