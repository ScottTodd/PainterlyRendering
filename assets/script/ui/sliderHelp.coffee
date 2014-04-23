$ = require 'jquery'

###
We don't want to fire events *while* the slider is moving.
http://stackoverflow.com/questions/5165579/onchange-event-for-html5-range
###
@onSliderChange = (slider, onChange) ->
	timer = null
	slider.bind 'change', ->
		if timer?
			clearTimeout timer
		timer =
			setTimeout onChange, 100

@makeSlider = (klass, min = 0, max = 1, startVal = min, step = 0.01) ->
	slider = $ "<input type='range' class='#{klass}'/>"
	slider.attr 'min', min
	slider.attr 'max', max
	# TODO: Is there a better way to make continuous ranges?
	slider.attr 'step', step
	slider.val startVal
	slider

