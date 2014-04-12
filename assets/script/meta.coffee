{ type, typeEach } = require './check'

###
Generates a reader for each name in `names`.
The property must be named `_name`.
###
@read = (clazz, names...) ->
	type clazz, Function
	typeEach names, String

	names.forEach (name) ->
		clazz.prototype[name] = ->
			@["_#{name}"]
