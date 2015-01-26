
_ = require 'lodash'
debug = require('debug') 'data:postgres:crud:query'

ot = getUtility 'object-tree'

class ExtendOptions
	constructor: (ctx) ->
		# @Options = ctx

		@parseInclude ctx
		@parseSelector ctx

		return @
	parseInclude: (opts) ->
		@include = opts.include
	parseSelector: (opts)->
		self = @
		selectorFields = ['limit', 'offset', 'order']

		_.each selectorFields, (key) ->
			if not opts[key]
				return

			self[key] = opts[key]

class Options
	constructor: (options, model) ->
		# Create reference to Sequelize
		@.model = model

		# Save default options
		@.defOptions =  _.clone options

		# Create empty include array in context
		@.include = []

		# Start parse options
		@.parseOptions()

		return @
	parseOptions: () ->
		# Parse include models
		@.parseInclude()

		# Parse limits and offsets
		@.parseSelectorOptions()

		@.parseOrder()
	parseSelectorOptions: () ->
		self = @
		selectorFields = ['limit', 'offset']

		_.each selectorFields, (key) ->
			if not self.defOptions[key]
				return

			self[key] = self.defOptions[key]
	parseInclude: (options) ->
		self = @

		assocs = @model.associations

		debug 'parse model include of %s', @model.name

		_.each assocs, (model, name) ->
			if model.associationType is 'BelongsToMany'
				m = model.target

				attributes = Object.keys m.attributes

				toIncludeModel=
					association: model
					through:
						attributes: []
			else
				toIncludeModel =
					model: model.target

			self.include.push toIncludeModel
	parseOrder: () ->
		debug 'parse model order of %s', @model.name

		@.order = @.defOptions.order || []
	toExtend: () ->
		new ExtendOptions @

module.exports = Options
