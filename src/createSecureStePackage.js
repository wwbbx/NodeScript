// Generated by CoffeeScript 1.6.3
var createPackageExe, defaultCustomizedFileRootDir, fs, hqCommonFileRootDir, path, releaseFolder, sh, tempRootDir;

createPackageExe = "C:\\WCSS\\Ste\\STE_WN_SERVER\\PROJECTS\\DeveloperToolSet\\CreateStePackage\\PackageCreator.Console\\bin\\Debug\\CreatePackage.exe";

releaseFolder = "\\\\ste.chn.agilent.com\\ste_packages\\SecuredStePackages";

hqCommonFileRootDir = "\\\\ste.chn.agilent.com\\HQ_DIST_SERVER";

defaultCustomizedFileRootDir = "C:\\WCSS\\Ste\\STE_Default_Customized_Files\\srmuxroot";

tempRootDir = "C:\\srmuxroot_secure";

fs = require('fs');

sh = require('execSync');

path = require('path');

if (!fs.existsSync(hqCommonFileRootDir)) {
  console.log("Can't access to HQ Distribution Server shared folder.");
  return;
}

sh.exec("xcopy /Y /V " + hqCommonFileRootDir + "\\*.* " + tempRootDir);

sh.exec("xcopy /Y /V " + defaultCustomizedFileRootDir + "\\*.* " + tempRootDir);
