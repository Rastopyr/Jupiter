
_ = require 'lodash'
Sequelize = require 'sequelize'

ot = getUtility 'object-tree'

class Query
	constructor: (query) ->
		# Save default query
		@.defQuery = _.clone query

		# Create selector object for Sequelize
		@.selector = Sequelize.and()

		# Create statment query object
		@.curStateQuery = _.clone query

		# Chek query object for existing `or` statment
		if @.isOrState()
			@.orStatement()

		# Generate `and` query
		@.genSelector()

		return this
	isOrState: () ->
		ot.isExistKey @.defQuery, 'or'
	genSelector: () ->
		query = @.curStateQuery

		for k,v of query
			s = {}
			s[k] = v
			@.selector.args.push s

	orStatement: () ->
		query = @.curStateQuery

		for k,v of query
			if k is 'or'
				# orState = Sequelize.or.apply Sequelize, query[k]
				@.selector.args.push Sequelize.or query[k]
				delete query[k]

Query.create = (query) ->
	new Query query

module.exports = Query
