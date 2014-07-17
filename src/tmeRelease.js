// Generated by CoffeeScript 1.7.1
(function() {
  var action, archiveTmePlatformAgentSharedAddress, cp, devenv, fs, integrationTestDll, integrationTestSolutionDir, integrationTestSolutionFullPath, msbuild, msiFullPath, msiName, path, releaseNoteFileName, releaseShareAddress, setupProjectFolderName, setupProjectFullPath, setupProjectName, sh, solutionFolderName, solutionFullPath, solutionName, svnRoot, tmePlatformAgentRelativePath, version, vstest;

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
    tmePlatformAgentPath = path.join(svnRoot, "Platforms\\TME");
    console.log("");
    console.log("Reverting any local changes ...");
    command = "svn revert -R -q " + tmePlatformAgentPath;
    this.run(command, true);
    console.log("");
    console.log("Updating source code from SVN ...");
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

  exports.runTestCases = function() {
    var command;
    console.log("");
    console.log("Executing integration test cases ...");
    command = "\"" + vstest + "\" /InIsolation /Platform:x86 " + integrationTestDll;
    return this.run(command);
  };

  exports.develop = function() {
    var success;
    success = false;
    if (!success) {
      console.log("hit it.");
    }
    console.log('will exit immediately ...');
    process.exit();
    console.log("developing this script ...");
    success = -999;
    success = this.runTestCases();
    return console.log("success result is: " + success);
  };

  exports.release = function() {
    var command, source, success, target, targetName;
    this.update();
    success = false;
    success = this.build();
    if (!success) {
      console.log("Building TMEPlatformAgent.sln is failed. Can't proceed.");
    }
    this.getVersion(setupProjectFullPath, function(versionNumber) {
      return version = versionNumber;
    });
    setTimeout(function() {
      var a;
      return a = 100;
    }, 100);
    success = false;
    success = this.buildTestCases();
    if (!success) {
      console.log("Build integration test case solution failed. Can't proceed.");
      process.exit();
    }
    success = false;
    success = this.runTestCases();
    if (!success) {
      console.log("Integration Test failed, release stopped.");
      process.exit();
    }
    source = msiFullPath;
    targetName = msiName.replace(".msi", "_" + version + ".msi");
    target = path.join(releaseShareAddress, targetName);
    command = "copy /Y /V " + source + " " + target;
    this.run(command);
    this.archive();
    return this.CopyReleaseNote();
  };

  exports.buildTestCases = function() {
    var command;
    console.log("");
    console.log("Building VS2013 integration test cases solution ...");
    command = "\"" + msbuild + "\" " + integrationTestSolutionFullPath + " /t:Rebuild /p:Configuration=Debug;Platform=x86";
    return this.run(command);
  };

  exports.help = function() {
    console.log("CRS TME Extractor Distribution Script");
    console.log("This script is written by Node.js by Nixin Wang.");
    console.log("Below individual commands are available for your usage:");
    console.log("");
    console.log("update: will update SVN\\HubDataServices\\Trunk\\Platforms\\TME directory.");
    console.log("build: will call VS2008 devevn to build TmePlatformAgent.sln.");
    console.log("buildTest: will call msbuild to build VS2013 integrqation test cases solution.");
    console.log("test: will call vstest.console.exe to execute VS2013 integration test cases.");
    console.log("dev: will execute steps defined in 'develop()' module for develop this script purpose.");
    console.log("");
    console.log("release: will run 'update', 'build', 'buildTest', 'test' and finally release setup package to fas3000-b shared folder.");
    console.log("not implemented includes 'dist: distribute to TSPM server', 'branch: create branch for source code'");
    console.log("");
    return console.log("Example: coffee tmeRelease.coffee release");
  };

  exports.distribute = function() {
    return console.log('distributing ' + solutionName);
  };

  exports.branch = function() {
    return console.log('branch source code ...');
  };

  action = process.argv[2];

  switch (action) {
    case 'compile':
      this.compile();
      break;
    case 'build':
      this.build();
      break;
    case 'buildTest':
      this.buildTestCases();
      break;
    case 'release':
      this.release();
      break;
    case "test":
      this.runTestCases();
      break;
    case 'dist':
    case 'distribute':
      this.distribute();
      break;
    case 'update':
      this.update();
      break;
    case 'dev':
      this.develop();
      break;
    case 'help':
      this.help();
      break;
    default:
      console.log('unknown action: ' + action);
      console.log('Action choice: compile, build, release, dist/distribute');
  }

}).call(this);
