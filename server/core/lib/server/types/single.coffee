
http = require 'http'

bodyParser = require 'body-parser'
methodOverride = require 'method-override'

Application = require 'express'
RequestProto = require 'express/lib/request'
ResponseProto = require 'express/lib/response'

Logger = getLibrary 'core/logger'
ParentServer = getLibrary 'core/server'

Router = getLibrary 'core/server/protos/router'

error = getUtility 'error'

initMiddlawares = (options) ->
	options.bodyParser = options.bodyParser || {}

	bodyOptions = Object.keys options.bodyParser

	for op in bodyOptions
		if options.bodyParser[op]
			@use bodyParser[op] options.bodyParser[op]

	if options.override
		@use methodOverride()

class ParentServer.Single extends ParentServer
	constructor: (options) ->
		@options = options || {}

		@logger = new Logger.Logger
			transports: [
				new (Logger.transports.Console)()
			]

		@express = Application()
		@locals = @express.locals
		@express.lazyrouter()
		@router = @express._router

		initMiddlawares.call @express, options

		return @
	use: () ->
		@express.use.apply @express, arguments

		return @
	get: () ->
		if arguments.length is 1
			if 'string' is typeof arguments[0]
				return @express.get.apply @express, arguments

		@express.get.apply @express, arguments
		return @
	set: () ->
		@express.set.apply @express, arguments
		return @
	post: () ->
		@express.post.apply @express, arguments
		return @
	put: () ->
		if not @options.override
			error.throw 'PUT method not specified for this router', 'SRVRPUTNSPCFIED'
			return

		@express.put.apply @express, arguments

		return @
	delete: () ->
		if not @options.override
			error.throw 'PUT method not specified for this router', 'SRVRDELETENSPCFIED'
			return

		@express.delete.apply @express, arguments
		return @
	all: () ->
		@express.all.apply @express, arguments
		return @
	enable: () ->
		@express.enable.apply @express, arguments
		return @
	disable: () ->
		@express.disable.apply @express, arguments
		return @
	engine: () ->
		@express.engine.apply @express, arguments
		return @
	listen: () ->
		argArray = Array.prototype.slice.call arguments
		argArray = [@options.port].concat argArray

		@http = http.createServer.call http, @express
		@http.listen.apply @http, argArray

module.exports = ParentServer.Single
