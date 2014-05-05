three = require 'three'
GameObject = require './GameObject'

module.exports = class TexturedObject extends GameObject
	constructor: (@center, opts) ->
		material =
			new three.MeshBasicMaterial
				map: opts.texture

		@_mesh =
			new three.Mesh opts.geometry, material

	start: ->
		super()

		@graphics().scene().add @_mesh

	finish: ->
		super()
		@_mesh.removeFromGraphics @graphics()
