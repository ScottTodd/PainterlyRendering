GameObject = require './GameObject'
StrokeMeshLayer = require './StrokeMeshLayer'
StrokeMesh = require './StrokeMesh'
{ read } = require './meta'

module.exports = class SimpleStrokeMeshObject extends GameObject
	constructor: (@center, meshOpts) ->
		@_mesh =
			StrokeMesh.of meshOpts

	start: ->
		super()
		@_mesh.setPosition @center
		@_mesh.addToGraphics @graphics()

	finish: ->
		super()
		@_mesh.removeFromGraphics @graphics()

	read @, 'mesh'
