
_ = require 'lodash'
Sequelize = require 'sequelize'
should = require 'should'

index = require '../../../../../../../core/index'

Mapper = getLibrary 'data/mapper'
Pool = getLibrary 'core/data/mapper/pool'
Options = getLibrary 'data/crud/types/postgres/options'

settedModel =
	schema:
		name:
			type: Sequelize.STRING
			notNull: true
	name: 'User'
	options:
		tableName: 'unit-test'
	type: "Postgres"
	# associations:
	# 	hasMany: 'Parent'

settedModel2 =
	schema:
		name:
			type: Sequelize.STRING
			notNull: true
	name: 'Parent'
	options:
		tableName: 'unit-test4'
	type: "Postgres"
	

ctx = new Mapper
	database: 'unittest'
	type: 'Postgres'
	username: 'testuser'
	password: 'testpassword'
	logging: false

pool = new Pool 
	type: 'Postgres'
	ctx: ctx

# pool.set settedModel2
pool.set settedModel

fixtureModel = pool.get 'User'

methods = ['constructor', 'parseOptions', 'parseInclude', 'toExtend']
props = ['model', 'defOptions', 'include']


describe '#Data', ->
	describe '#Crud', ->
		describe '#Postgres', ->
			describe '#Options', ->
				it 'should be a function', ->
					Options.should.be.a.Function

				it 'should be have methods', ->
					options = new Options {}, fixtureModel

					_.each methods, (key) ->
						options.should.be.have.property(key).be.a.Function

				it 'should be have props', ->
					options = new Options {}, fixtureModel

					_.each props, (key) ->
						options.should.be.have.property key

				it '.model should be instanceof Sequelize.Model', ->
					options = new Options {}, fixtureModel

					options.model.should.be.instanceof Sequelize.Model

				it 'instance should have `[include]` property', ->
					options = new Options {}, fixtureModel

					options.should.have.property 'include'
					options.include.should.be.Array

				it '`[include]` property should have inctance of `Sequelize.Model`', ->
					options = new Options {}, fixtureModel

					_.each options.include, (model) ->
						model.should.be.instanceof Sequelize.Model

				it 'should have `limit` property', ->
					options = new Options
						limit: 1
					, fixtureModel

					options.should.have.property 'limit'
					options.limit.should.be.Number
					options.limit.should.be.eql 1

				it 'should have `offset` property', ->
					options = new Options
						offset: 10
					, fixtureModel

					options.should.have.property 'offset'
					options.offset.should.be.Number
					options.offset.should.be.eql 10

				it 'should have `order` property', ->
					order = ['name ASC']

					options = new Options
						order: order
					, fixtureModel

					options.should.have.property 'order'
					options.order.should.be.Array
					options.order.should.be.eql order

				it '.toExtend sould be return simple object with correct parameters', ->
					opts =
						offset: 10,
						limit: 1
						order: ['name ASC']

					options = new Options opts, fixtureModel

					toExtend = options.toExtend()

					toExtend.should.be.Object

					props = ['offset', 'limit', 'include']

					_.each props, (prop) ->
						toExtend.should.have.property prop
						toExtend[prop].should.eql options[prop]

					toExtend.should.have.property 'include'
					toExtend.include.should.be.Array

					_.each toExtend.include, (model) ->
						model.should.be.instanceof Sequelize.Model
