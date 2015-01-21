
_ = require 'lodash'
Sequelize = require 'sequelize'

Mapper = getLibrary 'core/data/mapper'
Pool = getLibrary 'core/data/mapper/pool'

Query = getLibrary 'core/data/crud/types/postgres/query'
Options = getLibrary 'core/data/crud/types/postgres/options'

error = getUtility 'core/error'

class PostgresCrud
	constructor: (options) ->
		@options =
			modelName: ''
	
		_.extend @options, options
	
		if not @options.modelName
			error.throw "Model name in Crud instance not exist", "MDLNAMENEXST"
	
		if @options.ctx
			if @options.ctx not instanceof Sequelize
				error.throw "Ctx not instance of Sequelize", "CTXNSEQLZ"
		else
			ctxOpts = _.extend @options, type: 'Postgres'
	
		@options.ctx = new Mapper ctxOpts

		if not @options.pool
			poolOpts =
				type: 'Postgres'
				ctx: @options.ctx
	
			@options.pool = new Pool poolOpts

		model = @options.pool.get @options.modelName

		if not model
			error.throw "Model #{@options.modelName} not exist in pool", "MDLNMNEXSTPOOL"

		@model = model

		return @

	create: (data, callback) ->
		model = @.model.build(data)

		model
			.save()
			.done (err, result) ->
				return callback err if err

				callback null, model

	findOne: (query, options, callback) ->
		if 'function' is typeof query
			callback = query
			query = {}
			options = {}

		if 'function' is typeof options
			callback = options
			options = {}

		if Object.keys(query).length
			query = Query.create query

		opts = new Options options, @model

		seQuery = _.extend where: query.selector || query, opts.toExtend()

		@model
			.find(seQuery)
			.done(callback)
	
	find: (query, options, callback) ->
		if 'function' is typeof query
			callback = query
			query = {}
			options = {}

		if 'function' is typeof options
			callback = options
			options = {}

		if Object.keys(query).length
			query = Query.create query

		opts = new Options options, @model

		seQuery = _.extend where: query.selector || query, opts.toExtend()

		@model
			.all(seQuery)
			.done(callback)

	update: (query, values, options, callback) ->
		if 'function' is typeof query
			error.throw 'Query not passed to `update` function', 'QRYNTPSSDTOUPDT'

		if 'function' is typeof options
			callback = options
			options = {}

		if Object.keys(query).length
			query = Query.create query

		opts = new Options options, @model

		seQuery = _.extend where: query.selector || query, opts.toExtend()

		@model
			.update(values, seQuery)
			.done callback

	destroy: (query, options, callback) ->
		if 'function' is typeof query
			callback = query
			options = {}
			query = {}

		if 'function' is typeof options
			callback = options
			options = {}

		if Object.keys(query).length
			query = Query.create query

		opts = new Options options, @model

		seQuery = _.extend where: query.selector || query, opts.toExtend()

		@model
			.destroy(seQuery)
			.done callback

exports.Postgres = PostgresCrud

module.exports = exports
