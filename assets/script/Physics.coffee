cannon = require 'cannon'
{ check, type } = require './check'
GameObject = require './GameObject'

module.exports = class Physics extends GameObject
	constructor: ->
		@world =
			new cannon.World

		# TODO: Understand these settings
		@world.broadphase =
			new cannon.NaiveBroadphase
		@world.solver.iterations =
			7
		@world.solver.tolerance =
			0.1
		@world.allowSleep =
			yes

		@_materials = {}

	material: (name) ->
		@_materials[name] ?= new cannon.Material

	addMaterialContact: (name1, name2, friction, restitution) ->
		@world.addContactMaterial new cannon.ContactMaterial \
			(@material name1),
			(@material name2),
			friction,
			restitution

	step: (dt) ->
		physicsSecondsPerRealSecond =
			1

		@world.step (dt * physicsSecondsPerRealSecond)

		for body in @world.bodies
			body.threeObject.position.copy body.position

			# For some reason, plain copy doesn't work.
			# body.threeObject.quaternion.copy body.quaternion
			tq = body.threeObject.quaternion
			bq = body.quaternion

			tq.x = bq.x
			tq.y = bq.y
			tq.z = bq.z
			tq.w = bq.w

	setGravity: (v) ->
		@world.gravity.set v.x, v.y, v.z

	addBody: (opts) ->
		materialName = opts.materialName ? fail()
		mass = opts.mass ? 0
		gameObject = opts.gameObject ? fail()
		threeObject = opts.threeObject ? fail()
		originalGeometry = opts.originalGeometry ? fail()
		center = opts. center ? fail()
		boundsType = 'box'

		shape =
			switch boundsType
				when 'box'
					originalGeometry.computeBoundingBox()
					{ min, max } =
						originalGeometry.boundingBox

					minv =
						new cannon.Vec3 min.x, min.y, min.z
					maxv =
						new cannon.Vec3 max.x, max.y, max.z

					halfExtent = new cannon.Vec3
					# write (maxv - minv) to halfExtent
					maxv.vsub minv, halfExtent
					# halve it
					halfExtent.mult 0.5, halfExtent

					new cannon.Box halfExtent

				else
					fail()

		body =
			new cannon.RigidBody mass, shape, @material materialName

		body.position.set center.x, center.y, center.z

		body.gameObject =
			gameObject
		body.threeObject =
			threeObject

		@world.add body

		body
