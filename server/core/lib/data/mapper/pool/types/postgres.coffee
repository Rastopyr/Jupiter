
util = require 'util'
path = require 'path'
join = path.join

debug = require('debug') 'data:postgres:mapper:pool'
dassoc = require('debug') 'data:postgres:mapper:pool:assoc'

_ = require 'underscore'
Sequelize = require 'sequelize'

fs = getLibrary 'core/fs'
error = getUtility 'core/error'
Walker = require 'walk'

modelPath = path.join pathes.app, 'model'

loadModels = (dir) ->
	self = @

	dir = dir || modelPath

	options =
		listeners:
			directories: (root, dirStatsArray, next) ->
				_.each dirStatsArray, (stat, kstat, list) ->
					pathToDir = join root, stat.name

					debug 'read directory %s', pathToDir
					loadModels.call self, pathToDir

					models = fs.loadDirJsSync pathToDir

					for model in models
						debug 'new model %s', model.name

						if not model.type
							continue

						if model.type isnt 'Postgres'
							continue

						self.set model
			errors: (root, nodeStatsArray, next) ->
				console.log nodeStatsArray

	Walker.walkSync dir, options

load = () ->
	@.initialLoading = true
	loadModels.call @

	debug 'end model loaded'

	@.initialLoading = false
	@.associateModels()

	@isLoaded = true

	return @

class PostgresPool
	isLoaded: false
	constructor: (options) ->
		ctx = options.ctx || null

		if not ctx
			error.throw "Ctx for PostgresPool not exist"

		if ctx and ctx not instanceof Sequelize
			error.throw "Ctx for PostgresPool is not instance of mongoose"

		@ctx = ctx
		load.call @

		return @
	sync: (callback) ->
		@ctx.sync()
			.then(()->
				callback()
			).catch(callback)
	get: (name) ->
		if @ctx.models[name]
			return @ctx.models[name]

		return null
	associateModels: () ->
		self = @
		sequelize = @.ctx

		_.each sequelize.models, (model, key, list) ->
			if not proto = model.proto
				return

			if not assocs = proto.options.associations
				return

			self.associateModel model, assocs, sequelize
	associateModel: (model, associations, sequelize) ->
		self = @

		_.each associations, (assoc, name, list) ->
			if associations instanceof Array
				return if 'string' is typeof assoc

				name = assoc.assocType

			if 'object' is typeof assoc
				if not assoc.modelName
					error.throw "Not exist model name for associations", "NTEXSTMDLNMFRASSOC"

				assocModel = sequelize.models[assoc.modelName]

				dassoc 'model "%s" have assoc to "%s" with type %s', model.name, assocModel.name, name

				model[name] assocModel, assoc

				return

			if 'string' is typeof assoc
				assocModel = sequelize.models[assoc]

				model[name] assocModel
				return
	set: (model) ->
		if not model.type or model.type is not "Postgres"
			error.throw "Setted model not for Postgres", "STTDMDLNFORPSTGRS"

		if not schema = model.schema
			error.throw "In model #{model.name} not exist schema field", "SCHMNEXST"

		if not options = model.options
			error.throw "In model #{model.name} not exist option field", "OPTSNEXST"

		self = @
		options.instanceMethods = _.extend {}, model.methods
		options.classMethods = _.extend {}, model.static

		if @ctx.models[model.name]
			@ctx.models[model.name] = null

		@ctx.define model.name, model.schema, model.options

		@.ctx.models[model.name].proto = model

		if not @.initialLoading and model.associations
			toAssocModel = @.ctx.models[model.name]
			assocs = model.associations

			@.associateModel toAssocModel, assocs, @.ctx

		@.ctx.models[model.name]

exports.Postgres = PostgresPool

module.exports = exports
