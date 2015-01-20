
###
#	Expose dependencies
###

path = require 'path'

_ = require 'lodash'
async = require 'async'

debug = require('debug') 'socket-handler'

###
#	Expose `Emitter`
###

Emitter = getLibrary 'socket/emitter'	

###
#	Expose `Handler`
###

typesFunctions =
	utility: getUtility
	controller: (string) ->
		getApplication path.join 'controller', string
	library: getLibrary
	middleware: (string) ->
		pathToMiddleware = path.join 'static/middleware', string

		getApplication pathToMiddleware

composeFunction = (func, emitter) ->
	return () ->
		if emitter._isSended
			return emitter

		args = Array.prototype.slice.call arguments

		next = args[args.length-1]

		return func emitter, next

class Handler
	constructor: (options) ->
		@.options = options
		@.pre = options.pre || []
		@.post = options.post || []

		@.emitter = Emitter options

		@compose = []

		@composeHandlers()

		return @
	composeHandlers: () ->
		self = @

		_.each @pre, (option, index) ->
			self.compose.push self.getHandler option.handler

		@.compose.push @.getHandler @.options.handler

		_.each @post, (option, index) ->
			self.compose.push self.getHandler option.handler

		@.compose = _.sortBy @.compose, (f, k) -> k*-1

	getHandler: (handler) ->
		func = undefined
		phandler = handler.entity

		if 'function' is typeof phandler
			func = phandler

		if 'string' is typeof phandler
			func = @getHandlerByString handler

		return composeFunction func, @.emitter

	getHandlerByString: (handler) ->
		typeOfHandler = undefined

		stringToHandler = handler.entity
		segments = stringToHandler.split '/'

		if typesFunctions[segments[0]]
			typeOfHandler = segments[0]

		if not typeOfHandler
			return getApplication stringToHandler

		segmentsWithoutType = stringToHandler.split('/')
		segmentsWithoutType.shift()

		pathToHandler = segmentsWithoutType.join path.sep

		lhandler = typesFunctions[typeOfHandler] pathToHandler

		if not handler.key
			return lhandler

		return lhandler[handler.key]
	
	execHandlers: (data, socket) ->
		debug 'exec with socket %s on %s', @.socket.id, @.options.path

		self = @

		@.emitter.socket =self.socket
		@.emitter.body = data

		@.emitter.on 'send', (result) ->
			self.socket.send result

		composed = async.compose.apply async, @.compose

		composed (err, results) ->
			self.emitter.send results

module.exports = Handler
