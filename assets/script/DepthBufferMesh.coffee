fs = require 'fs'
three = require 'three'

module.exports = class DepthBufferMesh
	constructor: (geometry) ->
		@_geometry = geometry

		uniforms =
			{}

		attributes =
			{}

		@_material =
			new three.ShaderMaterial
				uniforms: uniforms
				attributes: attributes

				vertexShader: fs.readFileSync __dirname + '/../shader/depth.vs.glsl'
				fragmentShader: fs.readFileSync __dirname + '/../shader/depth.fs.glsl'

				# transparent: yes
				depthWrite: yes

		@mesh =
			new three.Mesh @_geometry, @_material
