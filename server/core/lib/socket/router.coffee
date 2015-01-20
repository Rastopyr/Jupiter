
debug = require('debug') 'socket-router'
_ = require 'lodash'
engine = require 'engine.io'

routeConfig = getLibrary('config').get('socket.routes')

Route = getLibrary 'socket/route'

class Router
	constructor: (server, options) ->
		if @ not instanceof Router
			return new Router server, options

		debug 'init router'

		@.routes = routeConfig

		@.handlers = {}

		@.engine = new engine.Server()
		@.engine.attach server

		@initRoutes()
		@bindEvents()
		
		return @

	initRoutes: () ->
		self = @

		_.each @routes, (item, key, list) ->
			# Link to route engine
			# 
			item.engine = self.engine

			route = new Route item

			self.handlers[route.path] = route

	parseMessage: (string) ->
		JSON.parse string
	bindEvents: () ->
		self = @

		@.engine.on 'connection', (socket) ->
			debug 'new connection %s', socket.id

			socket.on 'message', (string) ->
				object = self.parseMessage string

				debug 'message on %s', object.uri

				if not self.handlers[object.uri]
					return

				handler = self.handlers[object.uri]

				handler.initLayer object.data, socket

module.exports = Router
