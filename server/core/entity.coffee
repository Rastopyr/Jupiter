
path = require 'path'

pathFunc = () ->
	path.resolve path.join.apply path, arguments

basePath = pathFunc __dirname, '../../'
baseServerPath = pathFunc __dirname, '../'
coreBasePath = pathFunc __dirname
appBasePath = pathFunc __dirname, '../application'

epathes = 
	lib:
		core: pathFunc coreBasePath, 'lib'
		application: pathFunc appBasePath, 'lib'
	model:
		core: pathFunc coreBasePath, 'model'
		application: pathFunc appBasePath, 'model'
	utility:
		core: pathFunc coreBasePath, 'utility'
		application: pathFunc appBasePath, 'utility'
	controller:
		core: pathFunc coreBasePath, 'controller'
		application: pathFunc appBasePath, 'controller'
	base:
		core: coreBasePath
		application: appBasePath

validType = (type) ->
	if not type
		type = 'base'

	types = Object.keys epathes

	if type not in types
		type = 'base'

	return type

isGetFromApp = (parentPath) ->
	relateiveParentPath = parentPath.replace "#{basePath}#{path.sep}", ''

	folderExec = (relateiveParentPath.split path.sep)[1]

	if folderExec is 'core'
		false
	else true

getSafeModule = (path) ->
	try
		return require path
	catch err
		if err.code is 'MODULE_NOT_FOUND'
			return false

		throw err

getEntityPathes = (type, name) ->
	eName = path.normalize name

	if eName.match 'application|core'
		regexp = new RegExp "application|core(\\#{path.sep})?"
		eName = eName.replace regexp, ''

	ePathes = 
		app: pathFunc epathes[type].application, eName
		core: pathFunc epathes[type].core, eName

getEntity = (type, name) ->
	type = validType type
	ePathes = getEntityPathes type, name
	fromApp = isGetFromApp name

	if fromApp
		if module = getSafeModule ePathes.app
			return module

	return require ePathes.core

getLibrary = (name) ->
	getEntity 'lib', name

getUtility = (name) ->
	getEntity 'utility', name

getController = (name) ->
	name = "application/#{name}"
	getEntity 'controller', name

getApplication = (name) ->
	name = "#{name}"
	getEntity 'base', name

global.pathes =
	base: basePath
	core: coreBasePath
	app: appBasePath
	server: baseServerPath

global.getLibrary = getLibrary
global.getUtility = getUtility
global.getController = getController
global.getApplication = getApplication

