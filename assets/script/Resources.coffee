q = require 'q'
three = require 'three'
{ fail } = require './check'

get = (dict, key, dictName) ->
	if dict[key]?
		dict[key]
	else
		keys =
			"[#{(Object.keys dict).join ', '}]"

		fail "No #{dictName} is named #{key}. Did you mean one of #{keys}?"

loadTexture = (name) ->
	(new three.JSONLoader).load "model/#{name}.js", (geometry, materials) =>

module.exports = class Resources
	constructor: (allResources) ->
		@_textures =
			{ }
		@_geometries =
			{ }

		jsonLoader =
			new three.JSONLoader
		textureLoader =
			new three.TextureLoader

		modelPromises =
			allResources.models.map (modelName) =>
				def = q.defer()
				jsonLoader.load "model/#{modelName}.js", (geometry, materials) =>
					@_geometries[modelName] = geometry
					def.resolve()
				def.promise

		texturePromises =
			allResources.textures.map (textureName) =>
				def = q.defer()

				@_textures[textureName] =
					three.ImageUtils.loadTexture "texture/#{textureName}.png", null, ->
						def.resolve()

				def.promise

		@_promise =
			q.all (modelPromises.concat texturePromises)

	promise: ->
		@_promise

	geometry: (name) ->
		get @_geometries, name, 'geometry'

	texture: (name) ->
		get @_textures, name, 'texture'
