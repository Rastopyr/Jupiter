
debug = require('debug') 'socket-route'

Handler = getLibrary 'socket/handler'

###
#	Expose `Route`
###

class Route
	constructor: (options) ->
		@.options = options

		@.path = options.path
		@.engine = options.engine

		@.options.pre = options.pre || []
		@.options.post = options.post || []

		debug 'new %s', @.path

		# @initLayer()
	initLayer: (data, socket) ->
		layer = new Handler @.options

		layer.socket = socket

		layer.execHandlers data

		return layer

	# initHanlder: () ->
		# @startRoute @options

	# startRoute: (options) ->
	# 	self = @

	# 	options.path = @.path

	# bindEvents: () ->
		# self = @
		# engine = @.engine

		# debug 'bind %s', self.path		

		# engine.on 'connection', (socket) ->
			# socket.on self.path, (data) ->
			# 	
			# 	

			# 	layer.execHandlers data
			# socket.on 'message', (uri) ->
		# engine.on @.path, (data) ->



module.exports = Route

