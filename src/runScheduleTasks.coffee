fs = require 'fs'
sh = require 'execSync'

configureFile = "./scheduleTasks.txt"
fs.readFile(configureFile, (err, data)->
	String(data).split('\r\n').forEach (line)->
		if line.trim() != ""
			console.log "Running coffee #{line} ..."
			sh.exec("coffee #{line}")
	)
