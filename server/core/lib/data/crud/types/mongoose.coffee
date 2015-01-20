
mongoose = require 'mongoose'
_ = require 'underscore'

Mapper = getLibrary 'core/data/mapper'
Pool = getLibrary 'core/data/mapper/pool'

error = getUtility 'core/error'

class MongooseCrud
	constructor: (options) ->
		@options =
			modelName: ''

		_.extend @options, options

		if not @options.modelName
			error.throw "Model name in Crud instance not exist", "MDLNAMENEXST"

		if @options.ctx
			if @options.ctx not instanceof mongoose.Mongoose
				error.throw "Ctx not instance of mongoose.Mongoose", "CTXNMNGOOSE"
		else
			ctxOpts = _.extend @options, type: 'Mongoose'

			@options.ctx = new Mapper ctxOpts

		if not @options.pool
			poolOpts =
				type: 'Mongoose'
				ctx: @options.ctx

			@options.pool = new Pool poolOpts

		model = @options.pool.get @options.modelName

		if not model
			error.throw "Model #{@options.modelName} not exist in pool", "MDLNMNEXSTPOOL"

		@model = model

		return @
	create: (data, callback) ->
		model = new @model data

		model.save callback
	count: () ->
		@model.count.apply @model, arguments
	find: () ->
		@model.find.apply @model, arguments
	findOne: () ->
		@model.findOne.apply @model, arguments
	update: (query, updated, options, callback) ->
		if not query or not updated
			if not query
				error.throw "Not passed \"query\" parameter", "QURYNPSSD"
			if not updated
				error.throw "Not passed \"updated\" parameter", "UPDTDNPSSD"

		if 'function' == typeof options
			callback = options
			options = {}

		@model.update query, updated, options, callback
	updateOne: (query, updated, fields, options, callback) ->
		if not query or not updated
			if not query
				error.throw "Not passed \"query\" parameter", "QURYNPSSD"
			if not updated
				error.throw "Not passed \"updated\" parameter", "UPDTDNPSSD"

		if 'function' == typeof fields
			callback = fields
			fields = null
			options = {}

		if 'function' == typeof options
			callback = options
			options = {}

		@model.findOne query, fields, options, (err, model)->
			if err
				return callback err

			model = _.extend model, updated

			model.save callback
	removeOne: (query, callback) ->
		@model.findOne query, (err, model) ->
			if err
				return callback err

			model.remove callback
	remove: () ->
		@model.remove.apply @model, arguments

exports.Mongoose = MongooseCrud

module.exports = exports
