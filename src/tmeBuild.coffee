cp = require 'child_process'
path = require 'path'
fs = require 'fs'

devenv = "C:\\Program Files (x86)\\Microsoft Visual Studio 9.0\\Common7\\IDE\\devenv.com"

if !fs.existsSync(devenv)
	console.log 'devenv does not exists.'

# execute devenv.com command to build TMEPlatformAgent solution.
svnRoot = "C:\\SVN\\HubDataServices\\Trunk"

if !fs.existssync(svnroot)
	svnRoot = svnroot.replace("C:\\", "D:\\")

platformAgentWin7RelativePath = "Platforms\\TME\\PlatformAgent\\TmePlatformAgentWin7"
tmePlatformAgentSoluionFile = "TmePlatformAgentWin7.sln"

setupPackageRelativePath = "Platforms\\TME\\PlatformAgent\\TMEPlatformAgentSetup"
setupProjectFile = "TMEPlatformAgentSetup.vdproj"

tmePlatformAgentSolution = path.join(svnRoot, platformAgentWin7RelativePath,
                                     tmePlatformAgentSoluionFile)

tmeSetupProject = path.join(svnRoot, setupPackageRelativePath, setupProjectFile)

buildCommand = "\"#{@devenv}\" \"#{@tmePlatformAgentSolution}\" /Project \"#{@tmeSetupProject}\" /Rebuild Debug"
cp.exec(buildCommand, (err, stdout, stderr) ->
	if err
		console.log stderr
	else
		console.log stdout
	)
