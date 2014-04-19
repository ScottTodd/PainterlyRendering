GameObject = require './GameObject'
StrokeMeshLayer = require './StrokeMeshLayer'
StrokeMesh = require './StrokeMesh'

module.exports = class SimpleStrokeMeshObject extends GameObject
	constructor: (@center, meshOpts) ->
		@mesh = StrokeMesh.of meshOpts

	start: ->
		super()
		@mesh.setPosition @center
		@mesh.addToGraphics @graphics()
