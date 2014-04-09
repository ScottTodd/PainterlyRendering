three = require 'three'
#EffectComposer = (require 'three-effectcomposer') three
require './vendor/TrackballControls' # creates three.TrackballControls
StrokeMesh = require './StrokeMesh'
GameObject = require './GameObject'

module.exports = class Graphics
	constructor: ->
		@renderer =
			new three.WebGLRenderer
				alpha: yes

		@gameObjects =
			[]

		@originalMeshesParent =
			new three.Object3D()

		@strokeMeshesParent =
			new three.Object3D()

	bindToDiv: (div) ->
		@width =
			div.width()
		@height =
			div.height()

		@renderer.setSize @width, @height

		@camera =
			new three.PerspectiveCamera 75, @width / @height, 0.1, 1000
		@camera.rotateX -Math.PI/6
		@camera.position.y = 3
		@camera.position.z = 3

		@controls =
			new three.TrackballControls @camera
		@controls.target.set 0, 0, 0

		div.append @renderer.domElement

	attachGameObject: (gameObject) ->
		@gameObjects.push gameObject

	restart: ->
		if @scene?
			@scene.remove @originalMeshesParent
			@scene.remove @strokeMeshesParent

		@scene =
			new three.Scene()

		for gameObject in @gameObjects
			gameObject.addOriginalObjectToParent @originalMeshesParent
			gameObject.addStrokeObjectToParent @strokeMeshesParent

		@scene.add @originalMeshesParent
		@scene.add @strokeMeshesParent

	setOriginalMeshesVisibility: (visibility) ->
		@originalMeshesParent.visible = visibility
		@originalMeshesParent.traverse (child) ->
			child.visible = visibility

	setStrokeMeshesVisibility: (visibility) ->
		@strokeMeshesParent.visible = visibility
		@strokeMeshesParent.traverse (child) ->
			child.visible = visibility

	draw: ->
		@controls.update()

		# TODO: render only original meshes to a texture and write object ids
		# TODO: pass that texture into the next rendering pass

		@setOriginalMeshesVisibility false
		@setStrokeMeshesVisibility true

		@renderer.render @scene, @camera
