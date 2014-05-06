$ = require 'jquery'
{ check } = require '../check'
{ read } = require '../meta'

module.exports = class RadioSelector
	constructor: (opts) ->
		opts.name
		check opts.start in opts.options

		@_change =
			$.Callbacks()

		onChange = =>
			@_change.fire @get()

		buttons =
			for option in opts.options
				rad =
					($ "<input/>").attr
						type: 'radio'
						class: 'button'
						value: option
						name: opts.name
				text =
					($ "<span class='name'/>").text option
				rad.bind 'change', onChange

				if option == opts.start
					rad.attr 'checked', yes

				($ "<div class='single'/>").append rad, text

		@_div =
			($ "<form class='radioSelector'/>")
		@_div.append ($ "<div class='controlTitle2'/>").text opts.name
		@_div.append buttons...

	read @, 'change', 'div'

	get: ->
		(@_div.find ':checked').val()


