three = require 'three'
StrokeMesh = require './StrokeMesh'

module.exports = class GameObject
	constructor: ->
		# currently empty

	setScene: (scene) ->
		@scene = scene

		# TODO? when recreating the scene, we need to recreate the mesh.
		#       What is the value of restarting over just refreshing the page?
		@strokeMesh =
			new StrokeMesh(@center, @radius)

		scene.add @strokeMesh.strokeSystem

	removeFromScene: ->
		if @scene?
			@scene.remove(@strokeMesh.strokeSystem)

	createAsSphere: (center, radius) ->
		@center = center
		@radius = radius

		@strokeMesh =
			new StrokeMesh(center, radius)
