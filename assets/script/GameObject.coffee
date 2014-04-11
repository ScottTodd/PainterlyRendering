
module.exports = class GameObject
	addToGraphics: (graphics) ->
		null

	step: (dt) ->
		null

	registerGame: (game) ->
		@_game = game

	game: ->
		@_game

