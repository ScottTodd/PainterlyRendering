GameObject = require './GameObject'
StrokeMesh = require './StrokeMesh'

module.exports = class SimpleStrokeMeshObject extends GameObject
	constructor: (center, @meshes) ->
		mesh.setPosition center for mesh in @meshes

	start: ->
		super()
		mesh.addToGraphics @graphics() for mesh in @meshes
