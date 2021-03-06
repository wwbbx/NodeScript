// Generated by CoffeeScript 1.6.3
(function() {
  var command, createPackageExe, defaultCustomizedFileRootDir, fs, hqCommonFileRootDir, lastModifyTime, msiFileName, now, outputInstallMsi, path, releaseFolder, sh, stat, target, tempRootDir, xcopy, yesterday;

  xcopy = "C:\\Windows\\System32\\xcopy.exe";

  createPackageExe = "C:\\WCSS\\Ste\\STE_WN_SERVER\\PROJECTS\\DeveloperToolSet\\CreateStePackage\\PackageCreator.Console\\bin\\Debug\\CreatePackage.exe";

  releaseFolder = "\\\\ste.chn.agilent.com\\ste_packages\\SecuredStePackages";

  hqCommonFileRootDir = "\\\\ste.chn.agilent.com\\HQ_DIST_SERVER";

  defaultCustomizedFileRootDir = "C:\\WCSS\\Ste\\STE_Default_Customized_Files\\srmuxroot";

  tempRootDir = "C:\\srmuxroot_secure";

  outputInstallMsi = "C:\\temp\\SteInstaller.msi";

  fs = require('fs');

  sh = require('execSync');

  path = require('path');

  if (fs.existsSync(tempRootDir)) {
    console.log("Cleaning up " + tempRootDir + " directory ...");
    fs.rmdirSync(tempRootDir);
  }

  console.log("Creating " + tempRootDir + " directory ...");

  fs.mkdirSync(tempRootDir);

  if (!fs.existsSync(hqCommonFileRootDir)) {
    console.log("Can't access to HQ Distribution Server shared folder.");
    return;
  }

  console.log("For debug purpose, copying HQ files are comment out.");

  command = "" + xcopy + " " + hqCommonFileRootDir + " " + tempRootDir + " /E /Y /R /C";

  console.log("Copying default customized files ...");

  command = "" + xcopy + " " + defaultCustomizedFileRootDir + " " + tempRootDir + " /E /Y /R /C";

  sh.exec();

  console.log("Calling CreatePackage.exe to create secured package ...");

  sh.exec("" + createPackageExe + " -i " + tempRootDir + " -o " + outputInstallMsi);

  now = new Date();

  yesterday = new Date(now - (24 * 60 * 60 * 1000));

  stat = fs.statSync(outputInstallMsi);

  lastModifyTime = stat.mtime;

  if (lastModifyTime > yesterday) {
    console.log("" + (path.basename(outputInstallMsi)) + " is created successfully!");
  }

  msiFileName = path.basename(outputInstallMsi).replace(".msi", "" + (now.getFullYear()) + "-" + (now.getMonth()) + "-" + (now.getDate()) + ".msi");

  target = path.join(releaseFolder, msiFileName);

  console.log("Releasing " + msiFileName + " to " + releaseFolder + " ...");

  command = "" + xcopy + " " + outputInstallMsi + " " + target + " /Y /R /C";

  sh.exec(command);

  if (fs.existsSync(target)) {
    console.log("Release successfully!");
  }

  console.log("Finished.");

}).call(this);
