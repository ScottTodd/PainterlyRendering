three = require 'three'
#EffectComposer = (require 'three-effectcomposer') three

module.exports = class Graphics
	constructor: ->
		@renderer =
			new three.WebGLRenderer
				alpha: yes

		@originalMeshesParent =
			new three.Object3D

		@strokeMeshesParent =
			new three.Object3D

	bindToDiv: (div) ->
		@width =
			div.width()
		@height =
			div.height()

		@renderer.setSize @width, @height

		@camera.aspect = @width / @height
		@camera.updateProjectionMatrix()

		div.append @renderer.domElement

	restart: ->
		@scene =
			new three.Scene()

		@scene.add @originalMeshesParent
		@scene.add @strokeMeshesParent

		@setupLights()

		@camera =
			# aspect ratio will be changed in `bindToDiv`
			new three.PerspectiveCamera 75, 1, 0.1, 1000
		@scene.add @camera

	setupLights: ->
		@ambientLight =
			new three.AmbientLight 0x222222
		@scene.add @ambientLight

		@dirLights =
			[]

		dirLight1 =
			new three.DirectionalLight 0xffffff, 1.0
		dirLight1.position =
			new three.Vector3 1, 0, 0
		@dirLights.push dirLight1

		dirLight2 =
			new three.DirectionalLight 0xff0000, 3.0
		dirLight2.position =
			new three.Vector3 0, -1, 0
		@dirLights.push dirLight2

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

		@renderer.render @scene, @camera
