// Generated by CoffeeScript 1.6.3
(function() {
  var archiveTmePlatformAgentSharedAddress, command, cp, devenv, fs, integrationTestDll, integrationTestSolutionDir, integrationTestSolutionFullPath, msbuild, msiFullPath, msiName, path, releaseNoteFileName, releaseShareAddress, setupProjectFolderName, setupProjectFullPath, setupProjectName, sh, solutionFolderName, solutionFullPath, solutionName, svnRoot, tmePlatformAgentRelativePath, version, vstest;

  cp = require('child_process');

  path = require('path');

  fs = require('fs');

  sh = require('execSync');

  devenv = "C:\\Program Files (x86)\\Microsoft Visual Studio 9.0\\Common7\\IDE\\devenv.com";

  msbuild = "C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\MSBuild.exe";

  vstest = "C:\\Program Files (x86)\\Microsoft Visual Studio 12.0\\Common7\\IDE\\CommonExtensions\\Microsoft\\TestWindow\\vstest.console.exe";

  svnRoot = "C:\\SVN\\HubDataServices\\Trunk";

  tmePlatformAgentRelativePath = "Platforms\\TME\\PlatformAgent";

  releaseShareAddress = "\\\\fas3000-b.chn.agilent.com\\v6\\WCSS_Eng_STE\\TME_EXTRACTOR\\SOFTWARES";

  archiveTmePlatformAgentSharedAddress = path.join(releaseShareAddress, "TMEPlatformAgent");

  solutionFolderName = "TmePlatformAgentWin7";

  integrationTestSolutionDir = "TmePlatformAgent.IntegrationTest";

  solutionName = solutionFolderName + ".sln";

  setupProjectFolderName = "TMEPlatformAgentSetup";

  setupProjectName = setupProjectFolderName + ".vdproj";

  msiName = "TMEPlatformAgent.msi";

  releaseNoteFileName = "ReleaseNote.txt";

  solutionFullPath = path.join(svnRoot, tmePlatformAgentRelativePath, solutionFolderName, solutionName);

  setupProjectFullPath = path.join(svnRoot, tmePlatformAgentRelativePath, setupProjectFolderName, setupProjectName);

  msiFullPath = path.join(svnRoot, tmePlatformAgentRelativePath, setupProjectFolderName, "Debug", msiName);

  integrationTestSolutionFullPath = path.join(svnRoot, tmePlatformAgentRelativePath, integrationTestSolutionDir, integrationTestSolutionDir + ".sln");

  integrationTestDll = path.join(svnRoot, tmePlatformAgentRelativePath, integrationTestSolutionDir, integrationTestSolutionDir, "bin\\x86\\Debug", integrationTestSolutionDir + ".dll");

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

  exports.CopyReleaseNote = function() {
    var command, sourceReleaseNote, targetReleaseNote;
    sourceReleaseNote = path.join(svnRoot, tmePlatformAgentRelativePath, "TMEPlatformAgent", releaseNoteFileName);
    targetReleaseNote = path.join(releaseShareAddress, releaseNoteFileName);
    command = "copy /Y /V " + sourceReleaseNote + " " + targetReleaseNote;
    console.log('Copying ReleaseNote.txt to shared folder ...');
    return this.run(command);
  };

  exports.update = function() {
    var command, tmePlatformAgentPath;
    console.log("");
    console.log("Updating source code from SVN ...");
    tmePlatformAgentPath = path.join(svnRoot, "Platforms\\TME");
    command = "svn update " + tmePlatformAgentPath;
    return this.run(command, true);
  };

  exports.archive = function() {
    var allItem;
    console.log("");
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
    console.log("");
    console.log("Compiling " + solutionName + " ...");
    command = "\"" + devenv + "\" " + solutionFullPath + " /Rebuild Debug x86";
    console.log(command);
    return this.run(command);
  };

  exports.build = function() {
    var command;
    console.log("");
    console.log("Building " + msiName + " ...");
    command = "\"" + devenv + "\" " + solutionFullPath + " /Project " + setupProjectFullPath + " /Rebuild Debug x86";
    return this.run(command);
  };

  exports.buildTestCases = function() {
    return console.log("");
  };

  console.log("Building VS2013 integration test cases solution ...");

  command = "\"" + msbuild + "\" " + integrationTestSolutionFullPath + " /t:Rebuild /p:Configuration=Debug;Platform=x86";

  this.run(command);

}).call(this);
