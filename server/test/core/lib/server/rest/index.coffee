
mongoose = require 'mongoose'
should = require 'should'
_ = require 'underscore'
bodyParser = require 'body-parser'

index = require '../../../../../core/index'

Crud = getLibrary 'data/crud'
Rest = getLibrary 'core/server/rest'

Mapper = getLibrary 'core/data/mapper'
Pool = getLibrary 'core/data/mapper/pool'
Server = getLibrary 'core/server'

settedModel =
	schema:
		name:
			type: String
			required: true
		profile:
			firstName:
				type: String
	name: "User"
	options:
		collection: "test"
	type: "Mongoose"

MongooseMapper = new Mapper
	db: 'test'
	type: 'Mongoose'
	autoConnect: true

MongoosePool = new Pool
	type: 'Mongoose'
	ctx: MongooseMapper

MongoosePool.set settedModel

crudOpts =
	modelName: 'User'
	ctx: MongooseMapper
	pool: MongoosePool

MongooseCrud = new Crud 'Mongoose', crudOpts

restOpts =
	CRUD: MongooseCrud

createUserByCrud = (data, rootName, callback) ->
	toCreate = {}

	toCreate[rootName] = data

	userRest.post toCreate, callback

createUserByHttp = (data, expect, route, callback) ->
	request(server.express)
		.post(route)
		.send(data)
		.expect(expect)
		.expect('Content-Type', 'application/json; charset=utf-8')
		.end callback

describe '#Server', ->
	describe '#Rest', () ->
		it 'should be a FUnction', () ->
			Rest.should.be.a.Function

		it 'should have constructor', () ->
			rest = new Rest 'Mongoose', restOpts

			rest.should.have.property('constructor').be.Function

		it 'should return instance of REST', ->
			rest = new Rest 'Mongoose', restOpts

			rest.should.be.instanceof Rest

		it 'instance should have "http" function', () ->
			rest = new Rest 'Mongoose', restOpts

			rest.should.have.property('http').be.Function

		it '.http should have return function', () ->
			userRest = new Rest 'Mongoose', restOpts

			userRest.http().should.be.a.Function

		it 'should have property "get" function', () ->
			userRest = new Rest 'Mongoose', restOpts

			userRest.should.have.property('find').be.Function

		it 'should have property "post" function', () ->
			userRest = new Rest 'Mongoose', restOpts

			userRest.should.have.property('post').be.Function

		it 'should have property "getOne" function', () ->
			userRest = new Rest 'Mongoose', restOpts

			userRest.should.have.property('getOne').be.Function

		it 'should have property "patch" function', () ->
			userRest = new Rest 'Mongoose', restOpts

			userRest.should.have.property('patch').be.Function

		it 'should have property "put" function', () ->
			userRest = new Rest 'Mongoose', restOpts

			userRest.should.have.property('put').be.Function

		it 'should have property "deleteOne" function', () ->
			userRest = new Rest 'Mongoose', restOpts

			userRest.should.have.property('deleteOne').be.Function

		describe 'HTTP requests', () ->
			it 'GET should be return setted model', (done) ->
				server = new Server

				userRest = new Rest 'Mongoose', restOpts

				server.use '/rest/data', userRest.http()

				request = require 'supertest'

				userRest.post
					user:
						name: 'Senin Roman'
				, (err, result) ->
					should(err).be.eql null

					createdUser = result.user.toObject()
					createdUser._id = createdUser._id.toString()

					expected =
						success: true
						data:
							meta:
								totalCount: 1
							users: [createdUser]

					request(server.express)
						.get('/rest/data')
						.expect(expected)
						.expect('Content-Type', 'application/json; charset=utf-8')
						.end (err, res)->
							should(err).eql null

							userRest.deleteOne createdUser._id, done

			it 'POST should return error', (done) ->
				server = new Server

				userRest = new Rest 'Mongoose', restOpts

				server.use '/rest/data', userRest.http()

				request = require 'supertest'

				request(server.express)
					.post('/rest/data')
					.send({user: { name: "Romka Senin" }})
					.expect({success: false, err: 'Access denied'})
					.expect('Content-Type', 'application/json; charset=utf-8')
					.end done

			it 'POST should create model', (done) ->
				server = new Server

				userRest = new Rest 'Mongoose', restOpts

				server.use '/rest/data', bodyParser.json()
				server.use '/rest/data', bodyParser.urlencoded extended: true
				server.use '/rest/data', userRest.http isModified: true

				request = require 'supertest'

				request(server.express)
					.post('/rest/data')
					.send({user: { name: "Romka Senin" }})
					.expect('Content-Type', 'application/json; charset=utf-8')
					.end (err, res) ->
						should(err).eql null
						response = res.body
						user = response.data.user

						response.success.should.be.ok
						user.name.should.be.eql "Romka Senin"

						userRest.deleteOne user._id, done

			it 'PUT should update model', (done) ->
				server = new Server

				userRest = new Rest 'Mongoose', restOpts

				server.use '/rest/data', bodyParser.json()
				server.use '/rest/data', bodyParser.urlencoded extended: true
				server.use '/rest/data', userRest.http isModified: true

				request = require 'supertest'

				userRest.post
					user:
						name: 'Senin Roman'
				, (err, result) ->
					should(err).eql null

					createdUser = result.user.toObject()
					createdUser._id = createdUser._id.toString()
					delete createdUser.__v; # :(

					expected =
						success: true
						data:
							user: _.extend createdUser, name: "Renin Soma"

					request(server.express)
						.put('/rest/data/'+createdUser._id)
						.send({user: { name: "Renin Soma" } })
						.expect(expected)
						.expect('Content-Type', 'application/json; charset=utf-8')
						.end (err, res) ->
							should(err).eql null

							userRest.deleteOne createdUser._id, done

			it 'DELETE should remove mode;', (done) ->
				server = new Server

				userRest = new Rest 'Mongoose', restOpts

				server.use '/rest/data', bodyParser.json()
				server.use '/rest/data', bodyParser.urlencoded extended: true
				server.use '/rest/data', userRest.http isModified: true

				request = require 'supertest'

				userRest.post
					user:
						name: 'Senin Roman'
				, (err, result) ->
					should(err).eql null

					createdUser = result.user.toObject()
					createdUser._id = createdUser._id.toString()

					expected =
						success: true
						data:
							user: createdUser

					request(server.express)
						.delete('/rest/data/'+createdUser._id)
						.expect(expected)
						.expect('Content-Type', 'application/json; charset=utf-8')
						.end (err, res) ->
							should(err).eql null

							userRest.getOne createdUser._id, (err, result) ->
								should(err).eql null
								should(result.user).eql null

								done()

			# it 'should update nested data', (done) ->
			# 	server = new Server

			# 	userRest = new Rest 'Mongoose', restOpts

			# 	server.use '/rest/data', bodyParser.json()
			# 	server.use '/rest/data', bodyParser.urlencoded extended: true
			# 	server.use '/rest/data', userRest.http isModified: true

			# 	request = require 'supertest'

			# 	userRest.post
			# 		name: 'Senin Roman'
			# 	, (err, createdUser) ->
			# 		should(err).eql null

			# 		expected = createdUser.toObject()
			# 		expected._id = ""+expected._id
			# 		expected.profile =
			# 			firstName: "Roman"

			# 		request(server.express)
			# 			.put('/rest/data/'+expected._id)
			# 			.send({profile: { firstName: "Roman" }})
			# 			.expect('Content-Type', 'application/json; charset=utf-8')
			# 			.end (err, res) ->
			# 				should(err).eql null
			# 				response = JSON.parse res.text
			# 				user = response.data

			# 				response.success.should.be.ok
			# 				user._id.should.eql expected._id
			# 				user.should.have.property 'profile'
			# 				user.profile.should.have.property 'firstName'
			# 				user.profile.firstName.should.eql 'Roman'

			# 				userRest.deleteOne user._id, done

after () ->
	MongooseMapper.disconnect()