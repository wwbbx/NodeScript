# Create secured STE package and put it on web per Andrew Scotland's request.
# This script can be executed using coffee createSecureStePackage.coffee
# or node createSecureStePackage.js

xcopy = "C:\\Windows\\System32\\xcopy.exe"

createPackageExe = "C:\\WCSS\\Ste\\STE_WN_SERVER\\PROJECTS\\DeveloperToolSet\\CreateStePackage\\PackageCreator.Console\\bin\\Debug\\CreatePackage.exe"
releaseFolder = "\\\\ste.chn.agilent.com\\ste_packages\\SecuredStePackages"
hqCommonFileRootDir = "\\\\ste.chn.agilent.com\\HQ_DIST_SERVER"
defaultCustomizedFileRootDir = "C:\\WCSS\\Ste\\STE_Default_Customized_Files\\srmuxroot"

tempRootDir = "C:\\srmuxroot_secure"
outputInstallMsi = "C:\\temp\\SteInstaller.msi"


fs = require 'fs'
sh = require 'execSync'
path = require 'path'

# execute tf command to update default customized files.

# clean up tempRootDir
if fs.existsSync(tempRootDir)
	console.log "Cleaning up #{tempRootDir} directory ..."
	fs.rmdirSync(tempRootDir)

console.log "Creating #{tempRootDir} directory ..."
fs.mkdirSync(tempRootDir)

# copy all from HQ to C:\srmuxroot_secure
if ! fs.existsSync(hqCommonFileRootDir)
	console.log "Can't access to HQ Distribution Server shared folder."
	return

#console.log "Copying common files from HQ server ..."
console.log "For debug purpose, copying HQ files are comment out."
command = "#{xcopy} #{hqCommonFileRootDir} #{tempRootDir} /E /Y /R /C"
#sh.exec(command)

# copy customized files to temp root
console.log "Copying default customized files ..."
command = "#{xcopy} #{defaultCustomizedFileRootDir} #{tempRootDir} /E /Y /R /C"
sh.exec()

# execute CreatePackage.exe
console.log "Calling CreatePackage.exe to create secured package ..."
sh.exec("#{createPackageExe} -i #{tempRootDir} -o #{outputInstallMsi}")

# check outputInstallMsi file should not older than one day ago.
now = new Date()
yesterday = new Date(now - (24 * 60 * 60 * 1000))
stat = fs.statSync(outputInstallMsi)
lastModifyTime = stat.mtime

if lastModifyTime > yesterday
	console.log "#{path.basename(outputInstallMsi)} is created successfully!"


# copy SteInstaller.msi to shared folder with creation date stamp
msiFileName = path.basename(outputInstallMsi).replace(".msi", "#{now.getFullYear()}-#{now.getMonth()}-#{now.getDate()}.msi")

target = path.join(releaseFolder, msiFileName)
console.log "Releasing #{msiFileName} to #{releaseFolder} ..."
command = "#{xcopy} #{outputInstallMsi} #{target} /Y /R /C"
sh.exec(command)

if fs.existsSync(target)
	console.log "Release successfully!"

console.log "Finished."
