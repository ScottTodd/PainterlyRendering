three = require 'three'
{ check, type } = require './check'

vecScale = (v, scale) ->
	v.clone().multiplyScalar scale

shuffleEqually = (listA, listB, listC) ->
	check listA.length == listB.length == listC.length

	swap = (list, idx1, idx2) ->
		temp = list[idx1]
		list[idx1] = list[idx2]
		list[idx2] = temp

	for idx in [listA.length-1 .. 0] by -1
		swapIdx = Math.floor Math.random() * idx
		swap listA, idx, swapIdx
		swap listB, idx, swapIdx
		swap listC, idx, swapIdx

###
Can't simply use three.GeometryUtils.randomPointInTriangle
	because we need the normal too.

Done using barycentric coordinates.
The best reference for random selection I can find is
	<http://www.cs.fsu.edu/~banks/courses/2003.3/homework/hw.04.html>.
###
randomPointNormalUVInTriangle = (va, vb, vc, na, nb, nc, uva, uvb, uvc) ->
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

	uv = vecScale uva, alpha
	uv.add vecScale uvb, beta
	uv.add vecScale uvc, gamma

	[ point, normal, uv ]


###
Randomly distributres vertices across a mesh.
Assigns interpolated normals.
###
module.exports = meshVerticesNormalsUVs = (mesh, nVertices) ->
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
	uvs = []

	verticesOwed = 0

	for i in [0...geometry.faces.length]
		face = geometry.faces[i]

		[ va, vb, vc ] = faceVertices face
		[ na, nb, nc ] = face.vertexNormals
		[ uva, uvb, uvc ] = geometry.faceVertexUvs[0][i]

		area =
			three.GeometryUtils.triangleArea va, vb, vc

		verticesOwed += area * density

		nFacePoints =
			Math.round verticesOwed

		verticesOwed -= nFacePoints

		for _ in [0...nFacePoints]
			[ point, normal, uv ] =
				randomPointNormalUVInTriangle va, vb, vc,
					na, nb, nc,
					uva, uvb, uvc

			vertices.push point
			normals.push normal
			uvs.push uv

	check vertices.length == nVertices

	shuffleEqually vertices, normals, uvs

	[ vertices, normals, uvs ]
