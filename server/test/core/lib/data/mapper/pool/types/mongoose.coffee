
mongoose = require 'mongoose'
should = require 'should'

MongoosePool = getLibrary('data/mapper/pool/types/mongoose').Mongoose

settedModel =
	schema:
		name:
			type: String
			required: true
	name: "User"
	options:
		collection: "test"
	type: "Mongoose"

settedModelNotMongoose =
	schema:
		name:
			type: String
			required: true
	name: "User2"
	options:
		collection: "test"

options =
	ctx: mongoose

describe '#Data', ->
	describe '#Mapper', ->
		describe '#Pool', ->
			describe '#Mongoose', ->
				it 'should have constructor', () ->
					new MongoosePool(options).should.have.property('constructor').be.Function

				it 'should have reload function', ()->
					new MongoosePool(options).should.have.property('reload').be.Function

				it 'should have get function', () ->
					new MongoosePool(options).should.have.property('get').be.Function

				it 'should have set function', ->
					new MongoosePool(options).should.have.property('set').be.Function

				it '.set should set model to models ctx', () ->
					model = new MongoosePool(options).set settedModel

					model.modelName.should.be.eql settedModel.name
					model.collection.name.should.be.eql settedModel.options.collection

				it '#Pool.get should return eql setted model', () ->
					model = new MongoosePool(options).set settedModel

					gettedModel = new MongoosePool(options).get settedModel.name
					gettedModel.should.eql model
					gettedModel.should.eql new MongoosePool(options).ctx.models[settedModel.name]

				it '#Pool.get should not set model', () ->
					try
						new MongoosePool(options).set settedModelNotMongoose
					catch e
						e.message.should.eql "Setted model not for Mongoose"
						e.code.should.eql "STTDMDLNFORMNGOOS"

		after () ->
			mongoose.disconnect()
