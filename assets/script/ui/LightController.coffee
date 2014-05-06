$ = require 'jquery'
three = require 'three'
GameObject = require '../GameObject'
Light = require '../Light'
{ read } = require '../meta'
OnOffButton = require './OnOffButton'
Range = require './Range'

module.exports = class LightController extends GameObject
	constructor: (@_paramsControl, index) ->
		@_on =
			new OnOffButton
				class: 'lightOn'
				start: true

		@_lat =
			new Range
				name: 'Lat'
				min: -90
				max: 90
				start:
					if index == 0 then -30
					else if index == 1 then -12
					else -50
		@_long =
			new Range
				name: 'Long'
				min: -180
				max: 180
				start:
					if index == 0 then 0
					else if index == 1 then -110
					else 115
		@_hue =
			new Range
				name: 'Hue'
				min: 0
				max: 1
		@_sat =
			new Range
				name: 'Sat'
				min: 0
				max: 1
		@_lum =
			new Range
				name: 'Lum'
				min: 0
				max: 5
				scaleType: 'exponential'
				start: 2


		ranges =
			[ @_lat, @_long, @_hue, @_sat, @_lum ]
		rangeGroup =
			$ "<div class='rangeGroup'/>"
		for x in ranges
			rangeGroup.append x.div()

		@_div =
			$ "<div class='lightController'/>"
		@_div.append @_on.div(), rangeGroup

		# Handle changes
		for x in ranges.concat [ @_on ]
			x.change().add =>
				# console.log 'CHANGE!'
				@regenerate()

		@_light =
			new Light

	read @, 'div'

	start: ->
		@regenerate()
		@emit @_light

	regenerate: ->
		###
		if @_light?
			console.log 'KILL LIGHT'
			@_light.die()
			@_light = null

		if @_on.get()
			console.log 'ADD LIGHT'
			@_light =
				@emit new Light
					direction: @getDirection()
					hue: @_hue.get()
					sat: @_sat.get()
					lum: @_lum.get()
		###

		@_light.setDirection @getDirection()
		lum =
			if @_on.get()
				@_lum.get()
			else
				0
		@_light.setColor @_hue.get(), @_sat.get(), lum


	getDirection: ->
		phi =
			@_lat.get() * Math.PI / 180 + Math.PI / 2
		theta =
			@_long.get() * Math.PI / 180

		new three.Vector3 \
			(Math.cos theta) * (Math.sin phi),
			(Math.sin theta) * (Math.sin phi),
			Math.cos phi

