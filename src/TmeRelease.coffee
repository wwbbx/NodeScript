### Usage of this script ###
###
    "TmeRelease build" will build the TMEPlatformAgent solutionName
    "TmeRelease createPackage" will create TMEPlatformAgentSetup package
    "TmeRelease test" will execute all function tests for TMEPlatformAgent solutionName
    "TmeRelease release" will release TMEPlatformAgentSetup package and ReleaseNote.txt
    "TmeRelease distribute" will distribute TMEPlatformAgentSetup package to TSPM
                            and Lighthouse software download web page.
###

path = require 'path'
subversion = require './subversion'

class TmeRelease

	constructor: ()->
		@svnRoot = "C:\\SVN\\HubDataServices\\Trunk"
		@tmeSolutionRelativePath = "Platforms\\TME\\PlatformAgents\\TMEPlatformAgentWin7"
		@setupProjectRelativePath = @tmeSolutionRelativePath.replace(
		            'TmePlatformAgentWin7', 'TmePlatformAgentSetup')
		@solutionName = "TmePlatformAgentWin7.sln"
		@setupPackageName = "TmePlatformAgentSetup.msi"
		@releaseFolder = ""
		@tspmServer = "scgsbu08.scs.agilent.com"
		@lighthouseSoftwareServer = "www-ist.scs.agilent.com"
		@tspmReleasePath = ""
		@lighthouseDistPath = ""
		@packageVersion = "2.1.0"
		@devenvDefault = ''
		@devenv = ''

	updatePackageVersion: ->
		"2.1.0"

	useDevenv: (version)->
		@devenv = @devenvDefault.replace "version", version

	getTmePlatformAgentSolution: ->
		solutionNamePath = path.join(@svnRoot, @tmeSolutionRelativePath)
		path.join(solutionNamePath, @solutionName)

	getSetupPackageFullName: ->
		setupProjectFullPath = path.join(@svnRoot, @setupProjectRelativePath)
		path.join(setupProjectFullPath, "bin\\x86\\Debug\\#{@setupPackageName}")

	getVersionedPackageName: ->
		@packageVersion = @updatePackageVersion()
		"#{@setupPackageName}.replace('.msi', '')_#{@packageVersion}"

	getReleasedSetupPackage: ->
		path.join(@releaseFolder, @getVersionedPackageName())

	getTspmDistributedPackage: ->
		relativePackageName = path.join(@tspmReleasePath, @getVersionedPackageName())
		path.join("\\\\#{@tspmServer}", relativePackageName)

	update = ()->
		# revert all local changes.
		# update to latest.
		"updating #{@solutionName} ..."

		svn = new subversion()
		svn.update(getTmePlatformAgentSolution())

	compile = ()->
		useDevenv('9.0') if not @devenv

		"compiling #{@solutionName} ..."

		# calling devenv.com to compile TMEPlatformAgentWin7.sln


	test = ()->
		"executing function test cases for #{@solutionName} ..."

	build = ()->
		"building setup package for #{@solutionName} ..."

	release = ()->
		"releasing package to shared folder for #{@solutionName} ..."

	distribute = ()->
		"distributing package to TSPM and web page for #{@solutionName} ..."

	verifyScript = ()->
		message = "verifying this script switch function"
		console.log message
		message

	verifyProperty: ->
		message = 'verifying property'
		console.log message
		message

	execute: (command)->
		switch command
			when 'compile' then compile()
			when 'test' then test()
			when 'build' then build()
			when 'release' then release()
			when 'dist' then distribute()
			when 'verifyScript' then verifyScript()
			when 'verifyProperty' then go verifyProperty
			else
				console.log 'unknown command for TmeRelease'

module.exports = TmeRelease


