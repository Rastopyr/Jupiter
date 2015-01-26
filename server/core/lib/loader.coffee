
fs = require 'fs'
path = require 'path'

_ = require 'underscore'
argv = require('optimist').argv

class Loader
	getEntityName = (bundle) ->
		ext = path.extname bundle
		name = path.basename bundle, ext

	getModuleNameFromArg = (item) ->
		if item.match 'module-not_'
			return item.replace 'module_not', ''

		if item.match 'module_'
			return item.replace 'module_', ''

	parseBundle = (args) ->
		if not args['bundle']
			err = new Error
			err.message = 'Not bundle exist'
			err.code = 'BNDLNEXT'
			throw err

		if typeof args['bundle'] is not 'string'
			err = new Error
			err.message = 'Bundle options must be strings'
			err.code = 'BNDLOPTNVLD'
			throw err

		if not @bundles[args['bundle']]
			err = new Error
			err.message = 'Loader have not bundle '+args['bundle']
			err.code = 'BNDLNFND'
			throw err

		@bundleName = args['bundle']

	parseModule = (args) ->
		self = @
		@moduleOptions = {}
		keys = Object.keys args

		_.each keys, (item, key) ->
			prefix = item.match ///(module-not_|module_)///

			if not prefix
				return false

			name = item.replace prefix[0], ''

			self.moduleOptions[name] = {}

			if prefix is 'module-not_'
				self.moduleOptions[name].load = false

	parseOptions = (args) ->
		self = @
		keys = Object.keys args

		_.each keys, (item, key) ->
			prefix = item.match ///(option_)///

			if not prefix
				return false

			moduleMatch = item.match ///option_(.*)_.*///

			if not moduleMatch
				return false

			module = moduleMatch[1]
			valueNameMatch = item.match ///option_.*_(.*)///

			if not valueNameMatch
				return false 

			valueName = valueNameMatch[1]

			if not valueName
				return false

			value = args[item]
			self.moduleOptions[module] = {}
			self.moduleOptions[module][valueName] = value

	constructor: () ->
		@args = argv

		@bundlePath = path.join pathes.app, 'loader', 'bundle'
		@modulePath = path.join pathes.app, 'loader', 'module'
		@preloadBundles()
		@preloadModules()
		@parseArgs()

		return @

	preloadBundles: () ->
		self = @
		bundlePath = @bundlePath
		bundles = {}

		_.each fs.readdirSync(bundlePath), (item, ley) ->
			if item.match ///^\.///
				return false

			stat = fs.statSync path.join bundlePath, item
			
			if not stat.isFile()
				return false

			bundleName = self.bundleName = getEntityName item
			bundles[bundleName] = require path.join bundlePath, bundleName

		@bundles = bundles

	preloadModules: () ->
		self = @
		modulePath = @modulePath
		modules = {}

		_.each fs.readdirSync(modulePath), (item, key) ->
			if item.match ///^\.///
				return false

			moduleName = getEntityName item
			modules[moduleName] = require path.join self.modulePath, moduleName

		@modules = modules

	parseArgs: (args) ->
		args = args || argv

		parseBundle.call @, args
		parseModule.call @, args
		parseOptions.call @, args

	start: () ->
		self = @

		modules = @modules
		bundle = @bundles[@bundleName]

		_.each @moduleOptions, (module, name, list) ->
			bundle[name] = _.extend bundle[name], module

		options = bundle

		filteredOptions = _.filter options, (option, key, list) ->
			list[key].name = key 

			option.active = option.active || 0

			return option.active

		sortedOptions = _.sortBy filteredOptions, (option, key, list) ->
			option.priority = option.priority || 0

			return option.priority

		_.each sortedOptions, (option, key) ->
			module = modules[option.name]

			return if not module

			module.start option


		# _.each modules, (module, name, list) ->
		# 	option = options[name]

		# 	return if not option

		# 	if option.active == 1
		# 		module.start option


Loader.class = Loader

module.exports = exports = new Loader
