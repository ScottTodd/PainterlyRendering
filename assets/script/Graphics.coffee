three = require 'three'
#EffectComposer = (require 'three-effectcomposer') three
require './vendor/TrackballControls' # creates three.TrackballControls
StrokeMesh = require './StrokeMesh'

module.exports = class Graphics
	###
	@param container [jquery.Selector]
	###
	constructor: (@container) ->
		@width =
			@container.attr 'width'
		@height =
			@container.attr 'height'

		@scene =
			new three.Scene()
		@camera =
			new three.PerspectiveCamera 75, @width / @height, 0.1, 1000
		@camera.rotateX -Math.PI/6
		@camera.position.y = 3
		@camera.position.z = 3

		@renderer =
			new three.WebGLRenderer
		@renderer.setSize @width, @height

		@container.append @renderer.domElement

		# TODO: This is ugly code!
		@theMesh =
			new StrokeMesh @scene

		@t = 0

		@controls =
			new three.TrackballControls @camera
		@controls.target.set 0, 0, 0

		#cube =
		#	new three.Mesh (new three.CubeGeometry 2, 2, 2), @theMesh.material
		#@scene.add cube

	draw: ->
		@controls.update()

		@t =
			(@t + 0.01) % 2

		@theMesh.material.uniforms.bright.value =
			Math.min @t, 2 - @t

		@renderer.render @scene, @camera
