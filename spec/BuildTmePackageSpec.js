// Generated by CoffeeScript 1.6.3
var TmePackageBuilder, commonExpectedDevenv;

TmePackageBuilder = require('../src/TMEPackageBuilder');

commonExpectedDevenv = 'C:\\Program Files (x86)\\Microsoft Visual Studio version\\Common7\\IDE\\devenv.com';

describe('BuildTmePackage - Change Visual Studio devenv version', function() {
  it('should store specified devenv into devenvCommand property', function() {
    var builder;
    builder = new TmePackageBuilder;
    builder.useDevenvVersion('9.0');
    return expect(builder.devenvCommand).toEqual(commonExpectedDevenv.replace('version', '9.0'));
  });
  it('should return specified devenv.com version path', function() {
    var builder, version;
    builder = new TmePackageBuilder;
    version = builder.useDevenvVersion('9.0');
    return expect(version).toEqual(commonExpectedDevenv.replace('version', '9.0'));
  });
  return it('should return 10.0 devenv.com if specify 10.0', function() {
    var builder, version;
    builder = new TmePackageBuilder;
    version = builder.useDevenvVersion('10.0');
    return expect(version).toEqual(commonExpectedDevenv.replace('version', '10.0'));
  });
});
