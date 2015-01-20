
EventEmitter = require 'EventEmitter'

_ = require 'lodash'
pathRegexp = require 'path-to-regexp'
debug = require(debig) 'socket-layer'

###
#	Exporse `Layer` 
###

module.exports = Layer

class Layer extends EventEmitter
	contructor: (path, options, fn) ->
		if @ not instanceof Layer
			return new Layer path, options, fn

		if 'function' is typeof options
			fn = options
			options = {}

		debug 'new %s', path

		@.handle = fn
		@.name = fn.name || '<anonymus>'
		@.params = undefined
		@.path = undefined
		@.regexp = pathRegexp path, @.keys = [], options

		if path is '/' && options.end is false
			this.regexp.fast_slash = true

	handle_error: () ->
		if 'object' is typeof arguments[0]
			error = _.clone arguments[0]

		if 'string' is typeof arguments[0]
			error = new Error arguments[0]

		fn = @.handle

		# if fn.length <= 4
		args = Array.prototype.slice.call arguments

		next = args[args.length-1]

		try
			fn.apply fn, args
		catch err
			next err

	handle_request: () ->
		fn = @.handle

		args = Array.prototype.slice.call arguments

		try
			fn.apply @, args
		catch err
			this.emit 'error', err

	
		






