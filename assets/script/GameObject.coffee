{ read } = require './meta'

module.exports = class GameObject
	step: (dt) ->
		null

	registerGame: (game) ->
		@_game = game

	start: ->
		null

	read @, 'game'

	graphics: ->
		@game().graphics()

	physics: ->
		@game().physics()

	resources: ->
		@game().resources()


