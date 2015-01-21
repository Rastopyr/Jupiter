
util = require 'util'

redis = require 'redis'
_ = require 'lodash'

Config = getLibrary('config').get('database')

class RedisMapper
	constructor: (options) ->
		@client = redis.createClient()

		return @

exports.Redis = RedisMapper

module.exports = exports

