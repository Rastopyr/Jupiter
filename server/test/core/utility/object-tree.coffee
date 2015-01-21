
index = require '../../../core/index'
should = require 'should'

ot = getUtility 'object-tree'

fixtureObject =
	foo:
		foo:
			foo: 'bar'

describe '#Utility', ()->
	describe '#Object-tree', () ->
		describe '.isExist', ->
			it 'should have isExist method', () ->
				ot.should.have.property 'isExist'
				ot.isExist.should.have.be.Function

			it 'should return object', () ->
				ot.isExist(fixtureObject, foo: 'bar').should.be.Boolean

			it 'should return correct object from fixture', () ->
				ot.isExist(fixtureObject, foo: 'bar').should.be.ok

			it 'should be return false', () ->
				ot.isExist(fixtureObject, foo: 'barrr').should.be.not.ok

		describe '.isExistKey', ->
			it 'should have isExistKey method', ->
				ot.should.have.property 'isExistKey'
				ot.isExistKey.should.have.be.Function

			it 'should be return true', ->
				ot.isExistKey(fixtureObject, 'foo').should.be.ok

			it 'should be return false', ->
				ot.isExistKey(fixtureObject, 'bar').should.be.not.ok

		describe '.isExistValue', ->
			it 'should have isExistValue method', ->
				ot.should.have.property 'isExistValue'
				ot.isExistValue.should.have.be.Function

			it 'should be return true', ->
				ot.isExistValue(fixtureObject, 'bar').should.be.ok

			it 'should be return false', ->
				ot.isExistValue(fixtureObject, 'foo').should.be.not.ok
			

