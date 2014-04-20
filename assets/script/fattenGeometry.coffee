three = require 'three'
{ type } = require './check'

module.exports = fattenGeometry = (geometry, fattenAmount) ->
	type geometry, three.Geometry, fattenAmount, Number

	geometry.computeVertexNormals()

	vertexNormals = []
	for face in geometry.faces
		[ vertexNormals[face.a], vertexNormals[face.b], vertexNormals[face.c] ] =
			face.vertexNormals

	for idx in [0...geometry.vertices.length]
		# SphereGeometry apparently does not use every vertex...
		if vertexNormals[idx]?
			fattener = new three.Vector3
			fattener.copy vertexNormals[idx]
			fattener.multiplyScalar fattenAmount
			geometry.vertices[idx].add fattener

	null
