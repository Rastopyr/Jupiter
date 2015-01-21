
util = require 'util'
path = require 'path'
join = path.join

_ = require 'underscore'
mongoose = require 'mongoose'

fs = getLibrary 'core/fs'
error = getUtility 'core/error'
Walker = require 'walk'

modelPath = path.join pathes.app, 'model'

loadModels = (callback) ->
	self = @

	options =
		listeners:
			directories: (root, dirStatsArray, next) ->
				_.each dirStatsArray, (stat, kstat, list) ->
					pathToDir = join root, stat.name

					models = fs.loadDirJsSync pathToDir

					for model in models
						if not model.type
							continue

						if model.type isnt 'Mongoose'
							continue

						self.set model
				next()
			errors: (root, nodeStatsArray, next) ->
				console.log nodeStatsArray

	Walker.walkSync modelPath, options

load = () ->
	loadModels.call @, 
	@isLoaded = true

	return @

class MongoosePool
	isLoaded: false

	constructor: (options) ->
		ctx = options.ctx || null

		if not ctx
			error.throw "Ctx for MongoosePool not exist"

		if ctx and ctx not instanceof mongoose.Mongoose
			error.throw "Ctx for MongoosePool is not instance of mongoose"

		@ctx = ctx
		load.call @

		return @

	reload: () ->
		load.call @

		return @

	get: (name) ->
		if @ctx.models[name]
			return @ctx.models[name]

		return null

	set: (model) ->
		if not model.type or model.type is not "Mongoose"
			error.throw "Setted model not for Mongoose", "STTDMDLNFORMNGOOS"

		if not schema = model.schema
			error.throw "In model #{model.name} not exist schema field", "SCHMNEXST"

		if not options = model.options
			error.throw "In model #{model.name} not exist option field", "OPTSNEXST"

		schema = new @ctx.Schema schema, options

		if methods = model.methods
			_.extend schema.methods, methods

		if statics = model.static
			_.extend schema.static, statics

		if @ctx.models[model.name]
			@ctx.models[model.name] = null

		@ctx.model model.name, schema

exports.Mongoose = MongoosePool

module.exports = exports
