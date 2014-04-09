three = require 'three'
{ check, type } = require './check'

vecScale = (v, scale) ->
	v.clone().multiplyScalar scale

###
Can't simply use three.GeometryUtils.randomPointInTriangle
	because we need the normal too.

Done using barycentric coordinates.
###
randomPointAndNormalInTriangle = (va, vb, vc, na, nb, nc) ->
	beta = Math.random()
	gamma = Math.random()
	alpha = 1 - beta - gamma

	point = vecScale va, alpha
	point.add vecScale vb, beta
	point.add vecScale vc, gamma

	normal = vecScale va, alpha
	normal.add vecScale nb, beta
	normal.add vecScale nc, gamma

	[ point, normal ]


###
Randomly distributres vertices across a mesh.
Assigns interpolated normals.
###
module.exports = meshVerticesNormals = (mesh, nVertices) ->
	type mesh, three.Mesh

	geometry = mesh.geometry

	vertices = (face) ->
		[	geometry.vertices[face.a],
			geometry.vertices[face.b],
			geometry.vertices[face.c] ]

	totalArea = 0
	for face in geometry.faces
		totalArea += three.GeometryUtils.triangleArea (vertices face)...

	density = nVertices / totalArea

	geometry.computeFaceNormals()
	geometry.computeVertexNormals()

	vertices = []
	normals = []

	verticesOwed = 0

	for face in geometry.faces
		va = geometry.vertices[face.a]
		vb = geometry.vertices[face.b]
		vc = geometry.vertices[face.c]
		[ na, nb, nc ] = face.vertexNormals

		area =
			three.GeometryUtils.triangleArea va, vb, vc

		verticesOwed += area * density

		nFacePoints =
			Math.round verticesOwed

		verticesOwed -= nFacePoints

		for _ in [0...nFacePoints]
			[ point, normal ] = randomPointAndNormalInTriangle va, vb, vc, na, nb, nc
			vertices.push point
			normals.push normal

	console.log vertices.length
	console.log nVertices
	check vertices.length == nVertices

	[ vertices, normals ]