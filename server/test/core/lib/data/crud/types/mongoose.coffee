
path = require 'path'
fs = require 'fs'

_ = require 'underscore'
mongoose = require 'mongoose'
should = require 'should'

index = require '../../../../../../core/index'

Mapper = getLibrary 'core/data/mapper'
Pool = getLibrary 'core/data/mapper/pool'
Crud = getLibrary 'core/data/crud'

settedModel =
	schema:
		name:
			type: String
			required: true
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

describe '#Data', () ->
	describe '#Crud', ()->
		it 'should be a Function', () ->
			Crud.should.be.instanceof.Function

		it 'should be have property pool', () ->
			userCrud = new Crud 'Mongoose', crudOpts

			userCrud.options.should.be.have.property 'pool'
			userCrud.options.pool.should.be.eql crudOpts.pool

		it 'should be exist options.modelName', ()->
			userCrud = new Crud 'Mongoose', crudOpts

			userCrud.options.modelName.should.eql crudOpts.modelName

		it 'should be have "create" function', ()->
			userCrud = new Crud 'Mongoose', crudOpts

			userCrud.should.be.have.property('create').be.a.Function

		it 'should be have "findOne" function', ()->
			userCrud = new Crud 'Mongoose', crudOpts

			userCrud.should.be.have.property('findOne').be.a.Function

		it 'should be have "updateOne" function', ()->
			userCrud = new Crud 'Mongoose', crudOpts

			userCrud.should.be.have.property('updateOne').be.a.Function

		it 'should be have "removeOne" function', ()->
			userCrud = new Crud 'Mongoose', crudOpts

			userCrud.should.be.have.property('removeOne').be.a.Function

		it 'should be have "find" function', ()->
			userCrud = new Crud 'Mongoose', crudOpts

			userCrud.should.be.have.property('find').be.a.Function

		it 'should be have "remove" function', ()->
			userCrud = new Crud 'Mongoose', crudOpts

			userCrud.should.be.have.property('remove').be.a.Function

		it 'should be create user in database', (done) ->
			userCrud = new Crud 'Mongoose', crudOpts

			userCrud.create
				name: 'Roman'
			, (err, user) ->
				should(err).be.eql null

				user.name.should.be.eql 'Roman'

				userCrud.removeOne
					name: 'Roman'
				, done

		it 'should be return array of users in callback', (done) ->
			userCrud = new Crud 'Mongoose', crudOpts

			userCrud.create
				name: 'Roman'
			, (err, user) ->
				should(err).be.eql null

				userCrud.find
					name: 'Roman'
				, (err, users) ->
					should(err).be.eql null
					users.should.be.instanceof Array
					users.length.should.be.ok

					user = _.findWhere users, name: 'Roman'

					user.should.be.ok

					userCrud.removeOne
						name: 'Roman'
					, done

		it 'should be return one user in callback', (done) ->
			userCrud = new Crud 'Mongoose', crudOpts

			userCrud.create
				name: 'Roman'
			, (err, user) ->
				should(err).be.eql null

				userCrud.findOne
					name: 'Roman'
				, (err, finded) ->
					should(err).be.eql null
					finded.name.should.eql user.name

					userCrud.removeOne
						name: 'Roman'
					, done

		it 'should update all inserted models', (done) ->
			userCrud = new Crud 'Mongoose', crudOpts

			userCrud.create name: 'Ivan', (err, user) ->
				should(err).eql null

				user.should.be.ok

				userCrud.update
					name: 'Ivan'
				,	name: 'Egor'
				, (err, na, raw) ->
					should(err).eql null

					userCrud.find name: 'Egor', (err, egors) ->
						should(err).eql null

						na.should.be.eql egors.length

						userCrud.remove done

		it 'should update one model', (done) ->
			userCrud = new Crud 'Mongoose', crudOpts

			userCrud.create name: 'Ivan', (err, user) ->
				should(err).eql null

				user.should.be.ok

				userCrud.updateOne
					name: 'Ivan'
				,	name: 'Egor'
				,	'name'
				, 	{}
				, (err, egor) ->
					should(err).eql null

					userCrud.findOne name: 'Egor', (err, finded) ->
						should(err).eql null

						finded._id.should.be.eql egor._id

						userCrud.remove done

		it 'should remove all models', (done)->
			userCrud = new Crud 'Mongoose', crudOpts

			userCrud.create name: 'Ivan', (err, user) ->
				should(err).eql null

				user.should.be.ok

				userCrud.remove (err) ->
					should(err).eql null
					userCrud.find name: 'Ivan', (err, users) ->
						
						should(err).eql null
						users.length.should.eql 0

						done()

		it 'should remove one model', (done) ->
			userCrud = new Crud 'Mongoose', crudOpts

			userCrud.create name: 'Ivan', (err, user) ->
				should(err).eql null

				user.should.be.ok

				userCrud.remove (err) ->
					should(err).eql null
					userCrud.findOne name: 'Ivan', (err, user) ->
						
						should(err).eql null
						should(user).eql null

						done()

after () ->
	MongooseMapper.disconnect()
