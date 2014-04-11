three = require 'three'
require './vendor/TrackballControls' # creates three.TrackballControls
GameObject = require './GameObject'

module.exports = class CameraController extends GameObject
	constructor: (opts) ->
		@distance = opts?.distance ? 5

	addToGraphics: (graphics) ->
		graphics.camera.position.set 0, 0, @distance
		graphics.camera.lookAt new three.Vector3 0, 0, 0
		@controls = new three.TrackballControls graphics.camera
		@controls.target.set 0, 0, 0

	step: ->
		@controls.update()
