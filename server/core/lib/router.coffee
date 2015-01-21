
path = require 'path'

_ = require 'lodash'

ExpressRouter = getLibrary 'server/protos/router'

routeConfig = getLibrary('config').get('router')

httpMethodsByLetter =
	'G':
		method: 'get'
	'P':
		method: 'post'
	'U':
		method: 'put'
	'D':
		method: 'delete'

typesFunctions =
	utility: getUtility
	controller: (string) ->
		getApplication path.join 'controller', string
	library: getLibrary
	middleware: (string) ->
		pathToMiddleware = path.join 'static/middleware', string

		getApplication pathToMiddleware

methodsObjectByString = (string) ->
	returnedObject = {}

	if string is 'ALL'
		return use: ()->

	methods = _.map string, (letter) ->
		key = httpMethodsByLetter[letter].method

	methodObject = {}

	_.forEach methods, (method)->
		methodObject[method] = ()->

		returnedObject = _.extend methodObject

	return returnedObject

class Handler
	constructor: (string, handler) ->
		@object = methodsObjectByString string

		@processHandler handler

		return @object

	processHandler: (handler, object) ->
		loopObject = object || @object
		lhandler = handler.entity

		if 'function' is typeof lhandler

			if not loopObject
				return handler

			_.each loopObject, (value, key, list) ->
				list[key] = handler

			return

		if 'string' is typeof lhandler
			handlerFunc = @getHandlerByString handler

			if not loopObject
				return handlerFunc

			_.each loopObject, (value, key, list) ->
				list[key] = handlerFunc

			return

		if 'object' is typeof lhandler
			_.each handler, (val, key, list) ->
				if 'object' is typeof val
					throw new Error 'In handler '+handler+' is object.'

				loopObject[key] = @processHandler val

	getHandlerByString: (handler) ->
		stringToHandler = handler.entity
		segments = stringToHandler.split '/'

		if typesFunctions[segments[0]]
			typeOfHandler = segments[0]
		else
			typeOfHandler = ''

		if not typeOfHandler
			return getApplication stringToHandler

		segmentsWithoutType = stringToHandler.split('/')
		segmentsWithoutType.shift()

		pathToHandler = segmentsWithoutType.join path.sep

		lhandler = typesFunctions[typeOfHandler] pathToHandler

		if not handler.key
			return lhandler

		return lhandler[handler.key]

class Route
	constructor: (route)->
		@router = ExpressRouter()
		@options = route
		@options.pre = @options.pre || []
		@options.post = @options.post || []
		@prehandlers = []
		@posthandlers = []

		@initPreHandler()
		@initRoute()
		@initPostHandler();

		return @

	startRoute: (options) ->
		self = @
		handlerInstance = new Handler options.methods, options.handler

		_.each handlerInstance, (handler, key, list) ->
			if self.options.data
				handler = handler self.options.data

			if self.options.func
				handler = handler()

			self.router[key] self.options.path, handler

	initPreHandler: () ->
		self = @

		_.each @options.pre, (middleware, key, list) ->
			handler = self.startRoute middleware

	initPostHandler: ()->
		self = @
		_.each @options.post, (middleware, key, list) ->
			handler = self.startRoute middleware

	initRoute: () ->
		@startRoute @options

initRoutes = () ->
	self = @

	_.each @routes, (item, key, list) ->
		route = new Route item

		self.routesExpress.push route

class Router
	constructor: () ->
		this.router = ExpressRouter()

		@routes = routeConfig.routes
		@routesExpress = []

		initRoutes.call @
		@regenerateRoutes()

		return @
	regenerateRoutes: () ->
		self = @

		_.each @routesExpress, (router, key, list) ->
			self.router.use router.router


module.exports = Router
