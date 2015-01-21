
async = require 'async'
_ = require 'lodash'

find = (query, options, callback) ->
	fields = {}

	if options.fields
		keys = options.fields.split ' '
		_.each keys, (key, item, list) ->
			fields[key] = 1

	query = @CRUD.find query, fields, options

	if options.populate
		query.populate options.populate

	query.exec callback

count = (query, options, callback) ->
	if 'function' is typeof query
		callback = query
		query = {}
		options = {}

	if 'function' is typeof options
		callback = options
		options = {}

	@CRUD.count query, callback 

exportFind = (query, options, callback) ->
	self = @
	rootName = @CRUD.model.modelName.toLowerCase()+'s'

	if 'function' is typeof query
		callback = query
		query = {}
		options = {}

	if 'function' is typeof options
		callback = options
		options = {}

	if options.page
		options.limit = options.limit  || 10

		if options.startFromId
			query = _.extend
				selector:
					_id:
						$lte: options.startFromId
			, query

		if not options.startFromId
			options.skip = options.skip || 0

	async.parallel
		count: (next) ->
			count.apply self,
				[ query, options, next ]
		data: (next) ->
			find.apply self, 
				[ query, options, next ]
	, (err, results) ->
		return callback err if err

		data =
			meta:
				totalCount: results.count
				limit: options.limit
				skip: options.skip

		data[rootName] = results.data

		if options.page
			extended.page = page

		callback null, data

post = (body, params, callback) ->
	if 'function' is typeof params
		callback = params
		params = {}

	rootName = @CRUD.model.modelName.toLowerCase()

	@CRUD.create body[rootName], (err, model) ->
		return callback err if err

		data = {}

		data[rootName] = model

		callback null, data

getOne = (id, options, callback) ->
	fields = {}

	if options.fields
		keys = options.fields.split ' '
		_.each keys, (key, item, list) ->
			fields[key] = 1

	query = {}
	query[@idProp || '_id'] = id

	query = @CRUD.findOne query, fields

	if options.population
		query.populate options.population

	if not options.isModel
		query.lean()

	query.exec callback

exportsGetOne = (id, options, callback) ->
	self = @
	rootName = @CRUD.model.modelName.toLowerCase()

	if 'function' is typeof query
		callback = query
		query = {}
		options = {}

	if 'function' is typeof options
		callback = options
		options = {}

	getOne.call @, id, options, (err, result) ->
		return callback err if err

		data = {}
		data[rootName] = result

		callback null, data

patch = (id, body, params, callback)->
	fields = Object.keys(body).join ' '

	query = {}
	query[@idProp || '_id'] = id

	@CRUD.updateOne query, body, fields, params, callback

exportPatch = (id, body, params, callback) ->
	self = @
	rootName = @CRUD.model.modelName.toLowerCase()

	if 'function' is typeof params
		callback = params
		params = {}

	patch.call @, id, body[rootName], params, (err, result) ->
		return callback err if err

		data = {}

		data[rootName] = result

		callback null, data

put = patch

exportPut = exportPatch

deleteOne = (id, callback)->
	query = {}
	query[@idProp || '_id'] = id
	rootName = @CRUD.model.modelName.toLowerCase()
 
	@CRUD.removeOne query, (err, result) ->
		return callback err if err

		data = {}

		data[rootName] = result

		callback null, data	

filter = {
	count
	post
	deleteOne
}

filter.find = exportFind
filter.getOne = exportsGetOne
filter.patch = exportPatch
filter.put = exportPut

exports.Mongoose = filter

module.exports = exports
