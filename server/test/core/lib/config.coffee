
path = require 'path'
fs = require 'fs'

should = require 'should'
index = require '../../../core/index'

FS = new (getLibrary 'core/fs')

testedConfig =
	admin:
		name: "Roman"
		lastname: "Senin"

testedConfig2 =
	user:
		name: "Admin"
		lastname: "Adminich"

configName = "test.json"
configName2 = "test2.json"

pathToConf = path.resolve path.join appBasePath, 'config', configName
pathToConf2 = path.resolve path.join appBasePath, 'config', configName2

before ()->
	data = JSON.stringify testedConfig
	data2 = JSON.stringify testedConfig2

	FS.createFileSync pathToConf, data, {}
	FS.createFileSync pathToConf2, data2, {}

describe "#Config preloading", () ->
	it '#Config.reset should exists', ()->
		should.exist Config.reset

	it '#config.reset; admin object should be equal to tested', () ->
		Config.reset()
		should(Config.get('admin')).not.eql null

	it '#Config should be exists', () ->
		should(Config).not.be.false
		should(Config).not.eql null

	it '#Config.get; should be exists', () ->
		should.exist Config.get

	it '#Config.get; should be return true value', () ->
		adminName = Config.get 'admin.name'
		should(adminName).eql testedConfig.admin.name

	it '#Config.get; should be return object', () ->
		admin = Config.get 'admin'
		should(admin.name).eql testedConfig.admin.name

	it '#Config.get; should be return object', () ->
		config = Config.get()
		should(config.admin.name).eql testedConfig.admin.name

	it '#Config.get; multiple configs', () ->
		config = Config.get()
		should(config.user.name).eql testedConfig2.user.name

after () ->
	fs.unlinkSync pathToConf
	fs.unlinkSync pathToConf2
