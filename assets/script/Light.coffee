three = require 'three'
GameObject = require './GameObject'

module.exports = class Light extends GameObject
	constructor: (opts) ->
		opts ?= { }
		dir = opts.direction ? new three.Vector3 1, 0, 0
		hue = opts.hue ? 0
		sat = opts.sat ? 0
		lum = opts.lum ? 0

		@_light =
			new three.DirectionalLight 0xffffff, 1
		@setDirection dir
		@setColor hue, sat, lum

	start: ->
		@graphics().scene().add @_light

	finish: ->
		@graphics().scene().remove @_light


	setDirection: (dir) ->
		@_light.position.copy dir
		@_light.position.negate()

	setColor: (hue, sat, lum) ->
		@_light.color.setHSL \
			hue, sat, 0.5
		@_light.intensity =
			lum
