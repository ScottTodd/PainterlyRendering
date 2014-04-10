three = require 'three'
{ check, type } = require './check'

vecScale = (v, scale) ->
	v.clone().multiplyScalar scale

###
Can't simply use three.GeometryUtils.randomPointInTriangle
	because we need the normal too.

Done using barycentric coordinates.
The best reference for random selection I can find is
	<http://www.cs.fsu.edu/~banks/courses/2003.3/homework/hw.04.html>.
###
randomPointAndNormalInTriangle = (va, vb, vc, na, nb, nc) ->
	alpha =
		1 - Math.sqrt Math.random()
	beta =
		Math.random() * (1 - alpha)
	gamma =
		1 - alpha - beta

	point = vecScale va, alpha
	point.add vecScale vb, beta
	point.add vecScale vc, gamma

	normal = vecScale na, alpha
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

	faceVertices = (face) ->
		[	geometry.vertices[face.a],
			geometry.vertices[face.b],
			geometry.vertices[face.c] ]

	totalArea = 0
	for face in geometry.faces
		totalArea += three.GeometryUtils.triangleArea (faceVertices face)...

	density = nVertices / totalArea

	geometry.computeFaceNormals()
	geometry.computeVertexNormals()

	vertices = []
	normals = []

	verticesOwed = 0

	for face in geometry.faces
		[ va, vb, vc ] = faceVertices face
		[ na, nb, nc ] = face.vertexNormals

		area =
			three.GeometryUtils.triangleArea va, vb, vc

		verticesOwed += area * density

		nFacePoints =
			Math.round verticesOwed

		verticesOwed -= nFacePoints

		for _ in [0...nFacePoints]
			[ point, normal ] =
				randomPointAndNormalInTriangle va, vb, vc, na, nb, nc
			vertices.push point
			normals.push normal

	check vertices.length == nVertices

	[ vertices, normals ]