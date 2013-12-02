// Generated by CoffeeScript 1.6.3
var action, archiveTmePlatformAgentSharedAddress, cp, devenv, fs, msiFullPath, msiName, path, releaseShareAddress, setupProjectFolderName, setupProjectFullPath, setupProjectName, sh, solutionFolderName, solutionFullPath, solutionName, svnRoot, tmePlatformAgentRelativePath, version;

cp = require('child_process');

path = require('path');

fs = require('fs');

sh = require('execSync');

devenv = "C:\\Program Files (x86)\\Microsoft Visual Studio 9.0\\Common7\\IDE\\devenv.com";

svnRoot = "C:\\SVN\\HubDataServices\\Trunk";

tmePlatformAgentRelativePath = "Platforms\\TME\\PlatformAgent";

releaseShareAddress = "\\\\fas3000-b.chn.agilent.com\\v6\\WCSS_Eng_STE\\TME_EXTRACTOR\\SOFTWARES";

archiveTmePlatformAgentSharedAddress = path.join(releaseShareAddress, "TMEPlatformAgent");

solutionFolderName = "TmePlatformAgentWin7";

solutionName = solutionFolderName + ".sln";

setupProjectFolderName = "TMEPlatformAgentSetup";

setupProjectName = setupProjectFolderName + ".vdproj";

msiName = "TMEPlatformAgent.msi";

solutionFullPath = path.join(svnRoot, tmePlatformAgentRelativePath, solutionFolderName, solutionName);

setupProjectFullPath = path.join(svnRoot, tmePlatformAgentRelativePath, setupProjectFolderName, setupProjectName);

msiFullPath = path.join(svnRoot, tmePlatformAgentRelativePath, setupProjectFolderName, "Debug", msiName);

version = "0.0.0";

exports.getVersion = function(project, callback) {
  var content, lines, versionPattern;
  content = fs.readFileSync(project);
  lines = content.toString().split('\n');
  versionPattern = /\"ProductVersion\" = \"8:([0-9].[0-9].[0-9])\"/;
  return lines.forEach(function(line) {
    var match;
    match = line.match(versionPattern);
    if (match) {
      return callback(match[1].toString());
    }
  });
};

exports.run = function(command, verbose) {
  var result;
  console.log(command);
  result = sh.exec(command);
  if (!result.code) {
    if (verbose) {
      console.log(result.stdout);
    }
    return true;
  } else {
    console.log(result.stdout);
    console.log(result.stderr);
    return false;
  }
};

exports.archive = function() {
  var allItem;
  console.log('archiving old TMEPlatformAgent package to ' + archiveTmePlatformAgentSharedAddress);
  allItem = fs.readdirSync(releaseShareAddress);
  return allItem.forEach(function(item) {
    var command, match, target;
    if (fs.statSync(path.join(releaseShareAddress, item)).isDirectory()) {
      return;
    }
    match = item.match(/TMEPlatformAgent_([0-9].[0-9].[0-9]).msi/);
    if (!match) {
      return;
    }
    if (match[1] === version) {
      return;
    }
    target = path.join(archiveTmePlatformAgentSharedAddress, path.basename(item));
    command = "move /Y " + (path.join(releaseShareAddress, item)) + " " + target;
    console.log(command);
    return sh.exec(command);
  });
};

exports.compile = function() {
  var command;
  console.log("Compiling " + solutionName + " ...");
  command = "\"" + devenv + "\" " + solutionFullPath + " /Rebuild Debug x86";
  console.log(command);
  return this.run(command);
};

exports.build = function() {
  var command;
  console.log("Building " + msiName + " ...");
  command = "\"" + devenv + "\" " + solutionFullPath + " /Project " + setupProjectFullPath + " /Rebuild Debug x86";
  return this.run(command);
};

exports.release = function() {
  var a, command, source, success, target, targetName;
  success = this.build();
  this.getVersion(setupProjectFullPath, function(versionNumber) {
    return version = versionNumber;
  });
  setTimeout(function() {}, a = 100, 100);
  if (success) {
    console.log('build success');
  } else {
    console.log('build is failed. please use VS2008 IDE to correct errors.');
  }
  source = msiFullPath;
  targetName = msiName.replace(".msi", "_" + version + ".msi");
  target = path.join(releaseShareAddress, targetName);
  command = "copy /Y /V " + source + " " + target;
  this.run(command);
  return this.archive();
};

exports.distribute = function() {
  return console.log('distributing ' + solutionName);
};

action = process.argv[2];

switch (action) {
  case 'compile':
    this.compile();
    break;
  case 'build':
    this.build();
    break;
  case 'release':
    this.release();
    break;
  case 'dist':
  case 'distribute':
    this.distribute();
    break;
  default:
    console.log('unknown action: ' + action);
    console.log('Action choice: compile, build, release, dist/distribute');
}