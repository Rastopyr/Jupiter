
_ = require 'lodash'

findLinksByKey = (query, key) ->
	finded = []

	for k, v of query
		if v instanceof Array
			if k is key
				finded = finded.concat v
				continue

			continue

		if 'object' is typeof v
			isFinded = findByKey v, query

			finded = finded.concat isFinded
			# return isFinded if isFinded

		continue if k isnt key
		continue if not query[k]

		finded.push query

	return finded

findByKey = (query, key) ->
	finded = []

	for k, v of obj
		if v instanceof Array
			if k is key
				finded.push v
				continue

			continue

		if 'object' is typeof v
			isFinded = findByKey v, query

			finded.concat isFinded
			continue
			# return isFinded if isFinded

		continue if k isnt key
		continue if not query[k]

		finded.push query[k]

	return finded

isExist = (obj, query) ->
	for k, v of obj
		if v instanceof Array
			continue

		if 'object' is typeof v
			isFinded = isExist v, query

			if isFinded
				return true

		if not query[k]
			continue

		if query[k] isnt v
			continue

		return true

	return false

isExistKey = (obj, key) ->
	for k,v of obj
		if 'object' is typeof v
			findedKey = isExistKey v, key

			if findedKey
				return true

		return true if key is k

	return false

isExistValue = (obj, val) ->
	for k,v of obj
		if 'object' is typeof v
			findedVal = isExistValue v, val

			if findedVal
				return true

		return true if val is v

	return false

exports = {
	isExist
	isExistKey
	isExistValue
	findLinksByKey
}

module.exports = exports
