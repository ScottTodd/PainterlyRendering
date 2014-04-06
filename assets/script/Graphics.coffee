three = require 'three'
#EffectComposer = (require 'three-effectcomposer') three
require './vendor/TrackballControls' # creates three.TrackballControls
StrokeMesh = require './StrokeMesh'

module.exports = class Graphics
	constructor: ->
		@renderer =
			new three.WebGLRenderer
				alpha: yes

	bindToDiv: (div) ->
		@width =
			div.width()
		@height =
			div.height()

		@renderer.setSize @width, @height

		@camera =
			new three.PerspectiveCamera 75, @width / @height, 0.1, 1000
		@camera.rotateX -Math.PI/6
		@camera.position.y = 3
		@camera.position.z = 3

		@controls =
			new three.TrackballControls @camera
		@controls.target.set 0, 0, 0

		div.append @renderer.domElement


	restart: ->
		@scene =
			new three.Scene()

		# TODO: This is ugly code!
		@theMesh =
			new StrokeMesh @scene

	draw: ->
		@controls.update()

		@renderer.render @scene, @camera
