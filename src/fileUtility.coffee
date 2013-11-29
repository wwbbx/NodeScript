fs = require 'fs'
util = require 'util'

class utility
	constructor: ->

	lastModifiedTime: (file)->
		info = util.inspect(fs.stat(file))
		return info.mtime

module.exports = utility
