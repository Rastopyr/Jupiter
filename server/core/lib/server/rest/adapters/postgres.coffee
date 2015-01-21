
_ = require 'lodash'
Sequelize = require 'sequelize'

debug = require('debug') 'data:server:rest:postgres'

clojure =
	post: (payload, callback) ->
		@CRUD.create payload, callback
	find: (query, options, callback) ->
		@CRUD.find query, options, callback
	findOne: (query, options, callback) ->
		@CRUD.findOne query, options, callback
	update: (query, values, options, callback) ->
		@CRUD.update query, values, options, callback
	destroy: (query, options, callback) ->
		@CRUD.destroy query, options, callback

find = (query, options, callback) ->
	if 'function' is typeof query
		callback = query
		query = {}
		options = {}

	if 'function' is typeof options
		callback = options
		options = {}

	options.limit = options.limit || 10
	options.offset = options.offset || 0

	rootName = _.pluralize(@CRUD.model.name).toLowerCase()

	clojure.find.call @, query, options, (err, results) ->
		return callback err if err

		d = {}
		d[rootName] = results

		callback null, d

getOne = (id, options, callback) ->
	if 'function' is typeof id
		error.throw "Id not exist in REST GET query", "IDNTEXSTINRESTGET"

	if 'function' is typeof options
		callback = options
		options = {}

	query =
		id: id

	rootName = _.singularize(@CRUD.model.name).toLowerCase()

	clojure.findOne.call @, query, options, (err, result) ->
		return callback err if err

		d = {}
		d[rootName] = result

		callback null, d

patchOne = (id, values, options, callback) ->
	if 'function' is typeof id
		error.throw "Id not exist in REST PUT query", "IDNTEXSTINRESTPUT"

	if 'function' is typeof options
		callback = options
		options = {}

	self = @

	query =
		id: id

	rootName = _.singularize(@CRUD.model.name).toLowerCase()

	clojure.update.call @, query, values, options, (err, result) ->
		return callback err if err

		clojure.findOne.call self, query, options, (err, result) ->
			return callback err if err

			d = {}
			d[rootName] = result

			callback null, d

post = (data, options, callback) ->
	if 'function' is typeof options
		callback = options
		options = {}

	rootName = _.singularize(@CRUD.model.name).toLowerCase()

	clojure.post.call @, data, (err, result) ->
		return callback err if err

		d = {}
		d[rootName] = result

		callback null, d

deleteOne = (id, options, callback) ->
	if 'function' is typeof options
		callback = options
		options = {}

	query =
		id: id

	rootName = _.singularize(@CRUD.model.name).toLowerCase()

	clojure.destroy.call @, query, options, (err, result) ->
		return callback err if err

		d = {}
		d[rootName] = null

		callback null, d

putOne = patchOne

filter = {
	find
	post
	getOne
	putOne
	patchOne
	deleteOne
}

exports.Postgres = filter

module.exports = exports
