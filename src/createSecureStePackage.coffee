# Create secured STE package and put it on web per Andrew Scotland's request.
# This script can be executed using coffee createSecureStePackage.coffee
# or node createSecureStePackage.js

createPackageExe = "C:\\WCSS\\Ste\\STE_WN_SERVER\\PROJECTS\\DeveloperToolSet\\CreateStePackage\\PackageCreator.Console\\bin\\Debug\\CreatePackage.exe"
releaseFolder = "\\\\ste.chn.agilent.com\\ste_packages\\SecuredStePackages"
hqCommonFileRootDir = "\\\\ste.chn.agilent.com\\HQ_DIST_SERVER"
defaultCustomizedFileRootDir = "C:\\WCSS\\Ste\\STE_Default_Customized_Files\\srmuxroot"

tempRootDir = "C:\\srmuxroot_secure"

fs = require 'fs'
sh = require 'execSync'
path = require 'path'

# execute tf command to update default customized files.

# clean up tempRootDir
#if fs.existsSync(tempRootDir)
#	fs.rmdirSync(tempRootDir)
#	fs.mkdirSync(tempRootDir)

# copy all from HQ to C:\srmuxroot_secure
if ! fs.existsSync(hqCommonFileRootDir)
	console.log "Can't access to HQ Distribution Server shared folder."
	return

sh.exec("xcopy /Y /V #{hqCommonFileRootDir}\\*.* #{tempRootDir}")

# copy customized files to temp root
sh.exec("xcopy /Y /V #{defaultCustomizedFileRootDir}\\*.* #{tempRootDir}")

