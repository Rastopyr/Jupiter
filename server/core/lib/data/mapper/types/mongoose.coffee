
util = require 'util'
url = require 'url'

_ = require 'underscore'
mongoose = require 'mongoose'

Config = getLibrary('config').get('database')

class MongooseMapper extends mongoose.Mongoose
	constructor: (options) ->
		super

		defOpts =
			protocol: 'mongodb'
			hostname: 'localhost'
			port: 27017
			pathname: 'test'
			autoPreloading: false

		@options = _.extend @options, defOpts, Config, options

		if @options.db
			@db = @options.db
			delete @options.db

		if @options.autoConnect
			@connect()

		return @
	connect: () ->
		connString = @connectString()
		super connString, @options
	connectString: () ->
		@options.pathname = @db || @options.pathname

		if @options.user and @options.pwd
			@options.auth = (@options.user+':'+@options.pwd)

		url.format _.extend @options, slashes: true		

exports.Mongoose = MongooseMapper

module.exports = exports
