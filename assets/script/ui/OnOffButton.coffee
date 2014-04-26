$ = require 'jquery'
{ read } = require '../meta'

module.exports = class OnOffButton
	constructor: (opts) ->
		@_box =
			$ "<input type='checkbox'/>"

		@_box.attr 'checked', opts.start

		@_change =
			$.Callbacks()

		@_box.bind 'change', =>
			@_change.fire @get()

		@_div = $ "<div class='onOffDiv'/>"
		if opts.class?
			@_div.addClass opts.class

		@_div.append @_box

	read @, 'change', 'div'

	get: ->
		@_box.is ':checked'
