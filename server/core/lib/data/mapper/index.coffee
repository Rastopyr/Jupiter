
path = require 'path'
join = path.join

_ = require 'underscore'

fs = getLibrary 'core/fs'
string = getUtility 'core/string'
error = getUtility 'core/error'

class Mapper
	constructor: (options) ->
		type = 'Base'

		if 'string' is typeof options
			type = options

		options = options || {}

		if options.type
			type = options.type
			delete options.type

		@preload()

		if not @types[type]
			error.throw "Types #{type} not exist in mapper list", "MPPRNEXST"

		return new @types[type] options
	preload: () ->
		self = @
		self.types = {}

		pathToMappers = join pathes.core, 'lib/data/mapper', 'types'

		files = fs.readDirJsSync pathToMappers

		_.each files, (file, key, list) ->
			name = path.basename file, path.extname file
			mapperKey = string.capitalize name

			self.types[mapperKey] = require(join(pathToMappers, name))[mapperKey]

		return @

exports = Mapper

module.exports = exports
