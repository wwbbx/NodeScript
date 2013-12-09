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
#if fs.existsSync(tempRootDir)
#	console.log "Cleaning up #{tempRootDir} directory ..."
#	fs.rmdirSync(tempRootDir)
#
#console.log "Creating #{tempRootDir} directory ..."
#fs.mkdirSync(tempRootDir)

# copy customized files to temp root
console.log "Copying default customized files ..."
command = "#{xcopy} #{defaultCustomizedFileRootDir}\\*.* #{tempRootDir} /E /Y /R /C /F /V"
console.log command
result = sh.exec(command)
console.log result.stdout
console.log result

# execute CreatePackage.exe
#console.log "Calling CreatePackage.exe to create secured package ..."
#sh.exec("#{createPackageExe} -i #{tempRootDir} -o #{outputInstallMsi}")
