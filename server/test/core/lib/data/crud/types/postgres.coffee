
path = require 'path'
fs = require 'fs'

_ = require 'lodash'
Sequelize = require 'sequelize'
should = require 'should'

index = require '../../../../../../core/index'

Mapper = getLibrary 'core/data/mapper'
Pool = getLibrary 'core/data/mapper/pool'
Crud = getLibrary 'core/data/crud'

settedModel =
	schema:
		name:
			type: Sequelize.STRING
			notNull: true
	name: 'User'
	options:
		tableName: 'unit-test'
	type: "Postgres"

associatedModel =
	schema:
		name:
			type: Sequelize.STRING
			notNull: true
	name: 'Parent'
	options:
		tableName: 'unit-test'
	type: "Postgres"
	associations:
		belongsTo: 'User'

associatedModel2 =
	schema:
		name:
			type: Sequelize.STRING
			notNull: true
	name: 'Child'
	options:
		tableName: 'unit-test2'
	type: "Postgres"
	associations:
		belongsTo:
			modelName: 'Parent'
			as: 'ParentOfChild'
			foreignKey: 'parent_id'

associatedModel3 =
	schema:
		name:
			type: Sequelize.STRING
			notNull: true
	name: 'Parent2'
	options:
		tableName: 'unit-test3'
	type: "Postgres"
	associations:
		hasMany:
			modelName: 'Child2'
			as: 'ChildParent'
			foreignKey: 'parent_id'

associatedModel4 =
	schema:
		name:
			type: Sequelize.STRING
			notNull: true
	name: 'Child2'
	options:
		tableName: 'unit-test3'
	type: "Postgres"

PostgresMapper = new Mapper
	database: 'unittest'
	type: 'Postgres'
	username: 'testuser'
	password: 'testpassword'
	logging: false

PostgresPool = new Pool 
	type: 'Postgres'
	ctx: PostgresMapper

PostgresPool.set settedModel
PostgresPool.set associatedModel
PostgresPool.set associatedModel2
PostgresPool.set associatedModel4
PostgresPool.set associatedModel3

crudOpts =
	modelName: 'User'
	ctx: PostgresMapper
	pool: PostgresPool

getCrud = () ->
	new Crud 'Postgres', crudOpts

userObject =
	name: 'Senin Roman'

describe '#Data', () ->
	describe '#Crud', ()->
		describe '#Postgres', ->
			before (done) ->
				PostgresPool.sync done

			it 'shoud be associated model .belongsTo', () ->
				model = PostgresMapper.models.Parent

				model.associations.should.have.property 'User'
				model.attributes.should.have.property 'UserId'

			it 'shoud be associated model .belongsTo with options', () ->
				model = PostgresMapper.models.Child

				model.associations.should.have.property 'ParentOfChild'
				model.attributes.should.have.property 'parent_id'

			it 'should be associated model .hasMany with options', () ->
				modelOne = PostgresMapper.models.Parent2
				modelMany = PostgresMapper.models.Child2

				modelOne.associations.should.have.property "ChildParent"
				modelMany.attributes.should.have.property 'parent_id'

			it 'should be have property pool', () ->
				userCrud = getCrud()

				userCrud.options.should.be.have.property 'pool'
				userCrud.options.pool.should.be.eql crudOpts.pool

			it 'should be exist options.modelName', ()->
				userCrud = getCrud()

				userCrud.options.modelName.should.eql crudOpts.modelName

			it 'should be have "create" function', ()->
				userCrud = getCrud()

				userCrud.should.be.have.property('create').be.a.Function

			it 'should be create user in database', (done) ->
				userCrud = getCrud()

				userCrud.create userObject, (err, createdUser)->
					should(err).eql null

					createdUser.should.have.property('name')
					createdUser.name.should.eql userObject.name

					createdUser
						.destroy()
						.then(->
							done()
						).catch (err) ->
							done err

			it 'should be have "find" function', ()->
				userCrud = getCrud()

				userCrud.should.be.have.property('find').be.a.Function

			it 'should be return array of users in callback', (done) ->
				userCrud = getCrud()

				userCrud.create userObject, (err, createdUser)->
					should(err).eql null

					userCrud.find (err, results) ->
						should(err).eql null

						results.should.be.Array
						
						containedUser = _.findWhere results, id: createdUser.id
						containedUser.id.should.be.eql createdUser.id

						containedUser
							.destroy()
							.then(-> done())
							.catch done

			it 'should be return array with one user with custom id in callback', (done) ->
				userCrud = getCrud()

				userCrud.create userObject, (err, createdUser)->
					should(err).eql null

					userCrud.find id: createdUser.id, (err, results) ->
						should(err).eql null

						results.should.be.Array
						results.length.should.be.eql 1

						containedUser = _.findWhere results, id: createdUser.id
						containedUser.id.should.be.eql createdUser.id

						containedUser
							.destroy()
							.then(-> done())
							.catch done

			it 'should be have "findOne" function', ()->
				userCrud = getCrud()

				userCrud.should.be.have.property('findOne').be.a.Function

			it 'should be return one custom user in callback', (done) ->
				userCrud = getCrud()

				userCrud.create userObject, (err, createdUser)->
					should(err).eql null

					userCrud.findOne id: createdUser.id, (err, finedUser) ->
						should(err).eql null

						finedUser.should.be.Object

						finedUser.id.should.be.eql createdUser.id

						finedUser
							.destroy()
							.then(-> done())
							.catch done

			it 'should be have "update" function', ()->
				userCrud = getCrud()

				userCrud.should.be.have.property('update').be.a.Function

			it 'should be update and return updated user', (done) ->
				userCrud = getCrud()

				userCrud.create userObject, (err, createdUser) ->
					should(err).eql null

					query =
						id: createdUser.id

					values = 
						name: 'Steve Jobs'

					userCrud.update query, values, (err, countArr) ->
							should(err).eql null

							countArr.should.be.Array
							countArr.should.be.containEql 1

							userCrud.findOne id: createdUser.id, (err, findedUser) ->
								should(err).eql null

								findedUser.name.should.be.eql values.name

								findedUser
									.destroy()
									.then(-> done())
									.catch done

			it 'should be have `destroy` function', () ->
				userCrud = getCrud()

				userCrud.should.be.have.property('destroy')
				userCrud.destroy.should.be.Function

			it 'should destroying created object', () ->
				userCrud = getCrud()

				userCrud.create userObject, (err, createdUser) ->
					should(err).eql null

					userCrud.destroy id: createdUser.id, (err) ->
						should(err).eql null

						userCrud.findOne id: createdUser.id, (err, findedUser) ->
							should(err).eql null
							should(findedUser).eql null
