
_ = require 'lodash'
s = require 'underscore.string'
i = require 'underscore.inflection'

_.mixin s.exports()
_.mixin i.resetInflections()

start = () ->

exports = {
	start
}

module.exports = exports
