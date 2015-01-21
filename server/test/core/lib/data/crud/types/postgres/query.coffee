
_ = require 'lodash'
Sequelize = require 'sequelize'
should = require 'should'

index = require '../../../../../../../core/index'

Query = getLibrary 'data/crud/types/postgres/query'

methods = [ 'constructor', 'isOrState', 'orStatement' ]
props = [ 'defQuery', 'selector' ]

describe '#Data', ->
	describe '#Crud', ->
		describe '#Postgres', ->
			describe '#Query', ->
				it 'should be a function', ->
					Query.should.be.a.Function

				it 'should be have methods', ->
					query = new Query {}

					_.each methods, (key) ->
						query.should.be.have.property(key).be.a.Function

				it 'should be have props', ->
					query = new Query {}

					_.each props, (key) ->
						query.should.be.have.property key

				it 'should be generate `or` query', ->
					query = new Query or: [
						{ name: 'Roman'} ,
						{ name: 'Masha' }
					]

					query.selector.should.be.Object
					query.selector.should.have.property('args')
					query.selector.args.should.be.Array
					query.selector.args.should.containEql
						args: [[ { name: 'Roman' }, { name: 'Masha' } ]]


				it 'should be generate `and` and `or` query', ->
					query = new Query
						name: 'Roman',
						lastName: 'Senin'
						or: [
							{ age: 2 },
							{ age: 8 }
						]

					query.selector.args.should.containEql
						args: [[ { age: 2 }, { age: 8 } ]]
					query.selector.args.should.containEql { name: 'Roman'}, {lastName: 'Senin'}
