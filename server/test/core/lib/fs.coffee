
path = require 'path'
join = path.join

extraFs = require 'fs-extra'
should = require 'should'
_ = require 'underscore'

index = require '../../../core/index'

fs = getLibrary 'core/fs'

pathToDir = path.join pathes.server, 'test', 'files'
extensions = ['.js', '.coffee', '.json']

describe '#FS', ->
	it 'should be a fs-extra', ->
		fs.should.be.eql extraFs

	it 'should be preload file list', (done) ->
		fs.readDirJs pathToDir, (err, files) ->
			_.each files, (item, key, list) ->
				fileExt = path.extname item

				isJs = _.contains extensions, fileExt

				isJs.should.be.ok

			done()

	it 'should be sync preload file list', () ->
		files = fs.readDirJsSync pathToDir

		_.each files, (item, key, list) ->
			fileExt = path.extname item
			isContain = _.contains extensions, fileExt

			isContain.should.be.ok

	it 'should be load files', (done) ->
		fs.loadDirJs pathToDir, (err, files) ->
			fs.readDirJs pathToDir, (err, readedFiles) ->
				_.every readedFiles, (item, key, list) ->
					filePath = path.join pathToDir, item
					requiredFile = require filePath

					isContain = _.contains files, requiredFile

					isContain.should.be.ok


				done()

	it 'shoud be sync load files', () ->
		files = fs.loadDirJsSync pathToDir
		readedFiles = fs.readDirJsSync pathToDir

		_.every readedFiles, (item, key, list) ->
			filePath = path.join pathToDir, item
			requiredFile = require filePath

			isContain = _.contains files, requiredFile

			isContain.should.be.ok	
