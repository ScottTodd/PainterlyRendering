q = require 'q'
three = require 'three'
#EffectComposer = (require 'three-effectcomposer') three
{ check } = require './check'
{ read } = require './meta'
GameObject = require './GameObject'

module.exports = class Graphics extends GameObject
	constructor: ->
		@renderer =
			new three.WebGLRenderer
				alpha: yes

		depthTextureOptions =
			magFilter: three.NearestFilter
			minFilter: three.NearestFilter
			wrapS: three.ClampToEdgeWrapping
			wrapT: three.ClampToEdgeWrapping
			type: three.FloatType

		@_depthTexture =
			# TODO: don't hard-code size
			new three.WebGLRenderTarget 800, 600, depthTextureOptions

		@_strokeMeshes =
			[]

		@_divDefer = q.defer()

	read @, 'camera', 'depthTexture', 'scene', 'strokeMeshes'

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

	setupLights: ->
		@ambientLight =
			new three.AmbientLight 0x222222
		@_scene.add @ambientLight

		@dirLights =
			[]

		dirLight1 =
			new three.DirectionalLight 0xffffff, 0.8
		dirLight1.position.set -1, 0, -1
		@dirLights.push dirLight1

		dirLight2 =
			new three.DirectionalLight 0xffffff, 0.8
		dirLight2.position.set 0, -1, 1
		@dirLights.push dirLight2

		dirLight3 =
			new three.DirectionalLight 0xffffff, 0.8
		dirLight3.position.set 1, -1, 0
		@dirLights.push dirLight3

		for dirLight in @dirLights
			@_scene.add dirLight

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
