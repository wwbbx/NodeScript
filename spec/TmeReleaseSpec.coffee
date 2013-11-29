
path = require 'path'
subversion = require '../src/subversion'
fileUtility = require '../src/fileUtility'

describe 'TmeRelease script: ', ->

	TmeRelease = require '../src/TmeRelease'
	releaseManager = new TmeRelease()
	solution = releaseManager.getTmePlatformAgentSolution()

	utility = new fileUtility()

	it 'svn check changes after update is false', ->
		# TODO: let spec test use sample folder
		#       rather than real source code folder.
		comment = releaseManager.execute('update')

		# there should be no changes against server
		# if we call svn compare command.
		solutionParentFolder = path.dirname(solution) # TMEPlatformAgentWin7
		solutionParentFolder = path.dirname(solutionParentFolder) # PlatformAgents
		solutionParentFolder = path.dirname(solutionParentFolder) # TME

		svn = new subversion()
		hasChanges = svn.hasChange(solutionParentFolder)

		expected = 'no local changes'
		actual = if hasChanges then 'has local changes' else expected
		expect(expected).toBe actual


	it 'dll newer than compile time is true', ->
		# TODO: use one sample solution
		#       which can always build successfully.
		#       we just need to verify if this script
		#       works or not.
		timeBeforeCompile = new Date()
		comment = releaseManager.execute('compile')

		# make sure compiled dlls are not older than
		# the time we call compile command
		mainDll = path.join(solution, "bin\\x86\\Debug\\TMEPlatformAgent.dll")

		dllModifiedTime = utility.lastModifiedTime(mainDll)

		expected = 'dll is generated'
		actual = if dllModifiedTime > timeBeforeCompile then expected else 'dll is not generated'
		expect(expected).toBe actual


	it 'package are new created after build command', ->
		# TODO: change to use one sample setup project?
		#       it should be always build successfully
		#       if we use devenv.com correctly.
		#       should not use real TMEPlatformAgentSetup
		#       project because it might not be compiled
		#       successfully during development.
		timeBeforeBuild = new Date()
		comment = releaseManager.execute('build')

		# make sure setup package is not older than
		# the time we call build command.
		setupPackage = releaseManager.getSetupPackageFullName()

		setupPackageTime = utility.lastModifiedTime(setupPackage)

		expected = 'created setup package'
		actual = if setupPackageTime > timeBeforeBuild then expected else 'no setup package created'
		expect(expected).toBe actual


	it 'test run result are new created after calling test command', ->
		# TODO: run on one sample project
		#       because it should always get tests successful result.
		comment = releaseManager.execute('test')

		# check function test case result file is not older
		# than we call test command

		expect(comment).toContain 'executing function test '

	it 'package are new copied after release command', ->
		# TODO: use local folder for copying
		#       this is just to verify the script has
		#       copy capability.
		timeBeforeRelease = new Date()
		comment = releaseManager.execute('release')

		# setup package and release note is copied to shared folder.
		# their modified time is not older than the time of
		# running release command
		copiedSetupPackage = releaseManager.getReleasedSetupPackage()
		releasedPackageTime = utility.lastModifiedTime(copiedSetupPackage)

		expected = 'package is copied'
		actual = if releasedPackageTime > timeBeforeRelease then expected else 'not copied'
		expect(expected).toBe actual

	it 'TSPM package are new copied after distribute', ->
		# TODO: similar like above.
		timeBeforeDistribution = new Date()
		comment = releaseManager.execute('distribute')

		# setup package is copied to remote TSPM server
		# also it is available on Lighthouse download web page.
		distributedSetupPackage = releaseManager.getTspmDistributedPackage()

		distributedPackageTime = utility.lastModifiedTime(distributedSetupPackage)

		expected = 'copied to TSPM'
		actual = if distributedPackageTime > timeBeforeDistribution then expected else 'not copied to TSPM'
		expect(expected).toBe actual


	it 'can switch according to given command', ->
		comment = releaseManager.execute('verifyScript')

		expect(comment).toBe "verifying this script switch function"






