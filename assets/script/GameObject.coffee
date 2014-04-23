{ read } = require './meta'

module.exports = class GameObject
	step: (dt) ->
		null

	registerGame: (game) ->
		@_game = game

	read @, 'game'

	graphics: ->
		@game().graphics()

	physics: ->
		@game().physics()

	resources: ->
		@game().resources()

	emit: (obj) ->
		@game().addObject obj
		obj

	die: ->
		@_dead = yes

	dead: ->
		@_dead?

	start: ->
		null

	finish: ->
		null
