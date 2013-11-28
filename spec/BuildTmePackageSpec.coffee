TmePackageBuilder = require '../src/TMEPackageBuilder'

commonExpectedDevenv = 'C:\\Program Files (x86)\\Microsoft Visual Studio version\\Common7\\IDE\\devenv.com'

describe 'BuildTmePackage - Change Visual Studio devenv version', ->


    it 'should store specified devenv into devenvCommand property', ->
        builder = new TmePackageBuilder
        builder.useDevenvVersion '9.0'

        expect(builder.devenvCommand).toEqual commonExpectedDevenv.replace 'version', '9.0'


    it 'should return specified devenv.com version path', ->
        builder = new TmePackageBuilder
        version = builder.useDevenvVersion('9.0')

        expect(version).toEqual(commonExpectedDevenv.replace('version', '9.0'))

    it 'should return 10.0 devenv.com if specify 10.0', ->
        builder = new TmePackageBuilder
        version = builder.useDevenvVersion('10.0')

        expect(version).toEqual commonExpectedDevenv.replace 'version', '10.0'
