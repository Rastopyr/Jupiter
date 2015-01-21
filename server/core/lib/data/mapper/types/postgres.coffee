
Sequelize = require 'sequelize'

Config = getLibrary('config').get('postgres')

class PostgresMapper extends Sequelize
	constructor: (options) ->

		database = options.database || Config.database || 'postgres'
		username = options.username || Config.username || 'postgres'
		password = options.password || Config.password || ''

		options.dialect = 'postgres'

		super database, username, password, options


exports.Postgres = PostgresMapper

module.exports = exports

