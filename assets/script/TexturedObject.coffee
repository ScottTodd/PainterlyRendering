three = require 'three'
GameObject = require './GameObject'

module.exports = class TexturedObject extends GameObject
	constructor: (@center, opts) ->
		material =
			new three.MeshBasicMaterial
				map: opts.texture

		@mesh =
			new three.Mesh opts.geometry, material

	start: ->
		super()

		@graphics().scene.add @mesh
