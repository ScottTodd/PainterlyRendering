$ = require 'jquery'
GameObject = require './GameObject'

module.exports = class ScreenShooter extends GameObject
	constructor: (@_buttonSelector) ->

	start: ->
		($ 'document').ready =>
			($ @_buttonSelector).bind 'click', =>
				imgData = @graphics().imageDataURL()
				window.open \
					imgData,
					"toDataURL() image",
					"width=#{@graphics().width()}, height=#{@graphics().height()}"



