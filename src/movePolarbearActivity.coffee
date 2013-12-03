# move ACTIVITY log file on polarbear.chn.agilent.com to ste.chn.agilent.com

# some STE/WN 2.0 clients are still uploading ACTIVITY log to
# \\polarbear.chn.agilent.com\H$\Data\ActivityLog directory.
# File name format is like ActivityLog_24BRSTE81_20121018030101

# we need to copy those into \\ste.chn.agilent.com\D$\STE_Activity_Log_FTP

# simple process
# 1. based on file's last modified date to extract its Year, Month and Day.
# 2. Generate one archive folder named as Year.Month.Day if that folder is
#    not exists.
# 3. Copy single ACTIVITY log file to archived folder.
# 4. Copy archived file to \\ste.chn.agilent.com
# 5. Delete original ACTIVITY log file.

polarbearFtp = "\\\\polarbear.chn.agilent.com\\H$\\Data\\ActivityLog"
steFtp = "\\\\ste.chn.agilent.com\\D$\\STE_Activity_Log_FTP"

fs = require 'fs'
sh = require 'execSync'
path = require 'path'

if ! fs.existsSync(polarbearFtp)
	console.log "Can't access #{polarbearFtp}. Stopped."
	console.log "Make sure you have administrator permission on this shared drive."
	return

if ! fs.existsSync(steFtp)
	console.log "Can't access #{steFtp}. Stopped."
	console.log "Make sure you have administrator permission on this shared drive."
	return

# get all files on polarbear
allActivities = fs.readdirSync(polarbearFtp)
allActivities.forEach (activity)->
	itemFullPath = path.join(polarbearFtp, activity)
	stat = fs.statSync(itemFullPath)
	if stat.isFile()
		# prepare archive folder
		console.log "Processing #{itemFullPath} ..."
		lastModifiedTime = stat.mtime
		archiveFolder = path.join(polarbearFtp, "#{lastModifiedTime.getFullYear()}.#{lastModifiedTime.getMonth()}.#{lastModifiedTime.getDate()}")

		if ! fs.existsSync(archiveFolder)
			console.log "Creating archive folder: #{archiveFolder} ..."
			fs.mkdirSync(archiveFolder)

		# archive single activity log file.
		archiveActivity = path.join(archiveFolder, activity)

		console.log "Archiving #{activity} to #{archiveActivity} ..."
		sh.exec("move /Y #{itemFullPath} #{archiveFolder}")

		if !fs.existsSync(archiveActivity)
			console.log "Archive #{activity} has exception."
		else
			# copy to \\ste.chn.agilent.com
			target = path.join(steFtp, activity)

			sh.exec("copy /Y /V #{archiveActivity} #{target}")

			if fs.existsSync(target)
				console.log "Copied #{activity} to #{target} successfully!"


