three = require 'three'
{ type } = require './check'

module.exports = fattenGeometry = (geometry, fattenAmount) ->
	type geometry, three.Geometry, fattenAmount, Number

	fat =
		geometry.clone()

	fat.computeVertexNormals()

	vertexNormals = []
	for face in fat.faces
		[ vertexNormals[face.a], vertexNormals[face.b], vertexNormals[face.c] ] =
			face.vertexNormals

	for idx in [0...fat.vertices.length]
		# SphereGeometry apparently does not use every vertex...
		if vertexNormals[idx]?
			fattener = new three.Vector3
			fattener.copy vertexNormals[idx]
			fattener.multiplyScalar fattenAmount
			fat.vertices[idx].add fattener

	fat
