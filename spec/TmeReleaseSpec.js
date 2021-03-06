// Generated by CoffeeScript 1.6.3
var fileUtility, path, subversion;

path = require('path');

subversion = require('../src/subversion');

fileUtility = require('../src/fileUtility');

describe('TmeRelease script: ', function() {
  var TmeRelease, releaseManager, solution, utility;
  TmeRelease = require('../src/TmeRelease');
  releaseManager = new TmeRelease();
  solution = releaseManager.getTmePlatformAgentSolution();
  utility = new fileUtility();
  it('svn check changes after update is false', function() {
    var actual, comment, expected, hasChanges, solutionParentFolder, svn;
    comment = releaseManager.execute('update');
    solutionParentFolder = path.dirname(solution);
    solutionParentFolder = path.dirname(solutionParentFolder);
    solutionParentFolder = path.dirname(solutionParentFolder);
    svn = new subversion();
    hasChanges = svn.hasChange(solutionParentFolder);
    expected = 'no local changes';
    actual = hasChanges ? 'has local changes' : expected;
    return expect(expected).toBe(actual);
  });
  it('dll newer than compile time is true', function() {
    var actual, comment, dllModifiedTime, expected, mainDll, timeBeforeCompile;
    timeBeforeCompile = new Date();
    comment = releaseManager.execute('compile');
    mainDll = path.join(solution, "bin\\x86\\Debug\\TMEPlatformAgent.dll");
    dllModifiedTime = utility.lastModifiedTime(mainDll);
    expected = 'dll is generated';
    actual = dllModifiedTime > timeBeforeCompile ? expected : 'dll is not generated';
    return expect(expected).toBe(actual);
  });
  it('package are new created after build command', function() {
    var actual, comment, expected, setupPackage, setupPackageTime, timeBeforeBuild;
    timeBeforeBuild = new Date();
    comment = releaseManager.execute('build');
    setupPackage = releaseManager.getSetupPackageFullName();
    setupPackageTime = utility.lastModifiedTime(setupPackage);
    expected = 'created setup package';
    actual = setupPackageTime > timeBeforeBuild ? expected : 'no setup package created';
    return expect(expected).toBe(actual);
  });
  it('test run result are new created after calling test command', function() {
    var comment;
    comment = releaseManager.execute('test');
    return expect(comment).toContain('executing function test ');
  });
  it('package are new copied after release command', function() {
    var actual, comment, copiedSetupPackage, expected, releasedPackageTime, timeBeforeRelease;
    timeBeforeRelease = new Date();
    comment = releaseManager.execute('release');
    copiedSetupPackage = releaseManager.getReleasedSetupPackage();
    releasedPackageTime = utility.lastModifiedTime(copiedSetupPackage);
    expected = 'package is copied';
    actual = releasedPackageTime > timeBeforeRelease ? expected : 'not copied';
    return expect(expected).toBe(actual);
  });
  it('TSPM package are new copied after distribute', function() {
    var actual, comment, distributedPackageTime, distributedSetupPackage, expected, timeBeforeDistribution;
    timeBeforeDistribution = new Date();
    comment = releaseManager.execute('distribute');
    distributedSetupPackage = releaseManager.getTspmDistributedPackage();
    distributedPackageTime = utility.lastModifiedTime(distributedSetupPackage);
    expected = 'copied to TSPM';
    actual = distributedPackageTime > timeBeforeDistribution ? expected : 'not copied to TSPM';
    return expect(expected).toBe(actual);
  });
  return it('can switch according to given command', function() {
    var comment;
    comment = releaseManager.execute('verifyScript');
    return expect(comment).toBe("verifying this script switch function");
  });
});
