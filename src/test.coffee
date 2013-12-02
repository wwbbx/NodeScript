sh = require 'execSync'
fs = require 'fs'

source = "ftp://rmbmgr:violet@hpujcsc3.jpn.agilent.com/../../cscdbase/srmux/srm8/STE9000/SYSTEM/ACTIVITY"
target = "C:\\temp\\ACTIVITY.jpn"

if fs.existsSync(target)
	deleteCommand = "del /F /Q #{target}"
	sh.exec(deleteCommand)

copyCommand = "copy /Y /V #{source} #{target}"
console.log copyCommand
sh.exec(copyCommand)

if fs.existsSync(target)
	console.log "Copy successful"
else
	console.log "File is not copied"
