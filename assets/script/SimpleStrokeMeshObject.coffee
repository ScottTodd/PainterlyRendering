GameObject = require './GameObject'
StrokeMesh = require './StrokeMesh'

module.exports = class SimpleStrokeMeshObject extends GameObject
	constructor: (center, @mesh) ->
		@mesh.setPosition center

	start: ->
		super()
		@mesh.addToGraphics @graphics()
