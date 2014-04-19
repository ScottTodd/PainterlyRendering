fs = require 'fs'
three = require 'three'

module.exports = class DepthBufferMesh
	constructor: (geometry) ->
		@_geometry = geometry

		@_material =
			new three.ShaderMaterial
				uniforms: { }
				attributes: { }

				vertexShader: fs.readFileSync __dirname + '/../shader/depth.vs.glsl'
				fragmentShader: fs.readFileSync __dirname + '/../shader/depth.fs.glsl'

				depthWrite: yes

		@mesh =
			new three.Mesh @_geometry, @_material
