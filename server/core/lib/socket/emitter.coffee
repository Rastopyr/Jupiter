
events = require 'events'
EventEmitter = events.EventEmitter

###
#	Expose `Emitter`
###

class Emitter extends EventEmitter

	###
	#	Property, conained incoming data
	###
	body: {}

	###
	#	Property, contained data for middleware, or send to client
	###
	locals: {}

	###
	#	Property, contained info about current route
	###
	route: {
		path: '/'
	}

	###
	#	`true` if emitter send data.
	###
	_isSended: false

	constructor: (options) ->
		if @ not instanceof Emitter
			return new Emitter options

		options = options || {}

		@.route.path = options.path

	send: () ->
		this._isSended = true

		string = JSON.stringify 
			url: @.route.path
			data: @.locals

		this.emit 'send', string

module.exports = Emitter
