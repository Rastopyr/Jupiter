
should = require 'should'
mongoose = require 'mongoose'

index = require '../../../../../../core/index'

MongooseMaper = getLibrary('data/mapper/types/mongoose').Mongoose

describe '#Data', ->
	describe '#Mapper', ->
		describe '#Mongoose', ->
			it 'should be instance of mongoose.Mongoose', ->
				mapper = new MongooseMaper

				mapper.should.be.instanceof mongoose.Mongoose

			it 'should be have connectionString function', ->
				mapper = new MongooseMaper

				mapper.should.be.have.property 'connectString'

			it 'should return correct connection url', ->
				mapper = new MongooseMaper

				mapper.connectString().should.eql 'mongodb://localhost:27017/test'
				mapper.disconnect()

			it 'should return correct connection url with auth', ->
				mapper = new MongooseMaper
					user: 'Roman'
					pwd: '123'

				mapper.connectString().should.eql 'mongodb://Roman:123@localhost:27017/test'

			it 'should return correct connection url with database name', ->
				mapper = new MongooseMaper
					db: 'tested'

				mapper.connectString().should.eql 'mongodb://localhost:27017/tested'
