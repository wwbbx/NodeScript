sh = require 'execSync'
fs = require 'fs'
path = require 'path'

# map driver X: to \\hpujcsc3.jpn.agilent.com
# I don't want to share Japan server name and password
# So that on executing computer, there must be one
# driver mapped to \\hpujcsc3\srmuxroot.
# command: net use X: \\hpujcsc3.jpn.agilent.com\srmuxroot /USER:rmbmgr@hpujcsc3.jpn.agilent.com password
# delete this shared drive use: net use /DELETE X: /y

# source file is: X:\srmuxroot\STE9000\SYSTEM\ACTIVITY
# target file is: \\ste.chn.agilent.com\D$\STE_Activity_Log_FTP
# file should be renamed as ACTIVITY.hpujcsc3.20131203 style.
# we need to move ACTIVITY log file on Japan's server to ACTIVITY.hpujcsc3.20131203.

# simple process
# copy one ACTIVITY log file to be ACTIVITY.hpujcsc3.20131203 on Japan machine.
# copy ACTIVITY.hpujcsc3.20131203 to \\ste.chn.agilent.com
# if copy success, delete ACTIVITY on hpujcsc3.jpn.agilent.com

source = "X:\\srmuxroot\\STE9000\\SYSTEM\\ACTIVITY"

if !fs.existsSync(source)
	console.log "#{source} doesn't exist. Stopped."
	console.log "You may need to map \\\\hpujcsc3.jpn.agilent.com\\srmuxroot to X: first."
	return

now = new Date()
archiveName = "ACTIVITY.hpujcsc3.#{now.getFullYear()}#{now.getMonth() + 1}#{now.getDate()}"

# copy it for archive first
archiveFullPath = source.replace("ACTIVITY", archiveName)

console.log "Archiving #{source} to #{archiveFullPath} ..."
sh.exec("copy /Y /V #{source} #{archiveFullPath}")


# copy archived one to \\ste.chn.agilent.com
# this step must use my account or someone who is administrator on ste.chn
archiveFtpAddress = "\\\\ste.chn.agilent.com\\D$\\STE_Activity_Log_FTP"
target = path.join(archiveFtpAddress, archiveName)

console.log "Copying #{archiveFullPath} to #{target} ..."
sh.exec("copy /Y /V #{archiveFullPath} #{target}")

# if copy success
# delete original ACTIVITY log file.
console.log "Deleting #{source} ..."
if fs.existsSync(target) or fs.existsSync(archiveFullPath)
	sh.exec("del /F /Q #{source} /y")


