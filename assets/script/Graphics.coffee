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

		@originalMeshesParent =
			new three.Object3D

		@strokeMeshesParent =
			new three.Object3D

	read @, 'camera'

	bindToDiv: (div) ->
		@_width =
			div.width()
		@_height =
			div.height()

		@renderer.setSize @_width, @_height

		@resetAspect()

		div.append @renderer.domElement

	resetAspect: ->
		check @_width?
		@_camera.aspect = @_width / @_height
		@_camera.updateProjectionMatrix()

	restart: ->
		@scene =
			new three.Scene()

		@scene.add @originalMeshesParent
		@scene.add @strokeMeshesParent

		@setupLights()

		@_camera =
			# aspect ratio will be changed in `bindToDiv`
			new three.PerspectiveCamera 75, 1, 0.1, 1000

		if @_width?
			@resetAspect()

		@scene.add @_camera

	setupLights: ->
		@ambientLight =
			new three.AmbientLight 0x222222
		@scene.add @ambientLight

		@dirLights =
			[]

		dirLight1 =
			new three.DirectionalLight 0xffffff, 1.0
		dirLight1.position.set 0, -1, 0
		@dirLights.push dirLight1

		###
		dirLight2 =
			new three.DirectionalLight 0xff0000, 3.0
		dirLight2.position.set 0, -1, 0
		@dirLights.push dirLight2
		###

		for dirLight in @dirLights
			@scene.add dirLight

	setOriginalMeshesVisibility: (visibility) ->
		@originalMeshesParent.visible = visibility
		@originalMeshesParent.traverse (child) ->
			child.visible = visibility

	setStrokeMeshesVisibility: (visibility) ->
		@strokeMeshesParent.visible = visibility
		@strokeMeshesParent.traverse (child) ->
			child.visible = visibility

	draw: ->
		# TODO: render only original meshes to a texture and write object ids
		# TODO: pass that texture into the next rendering pass

		@setOriginalMeshesVisibility false
		@setStrokeMeshesVisibility true

		@renderer.render @scene, @_camera
