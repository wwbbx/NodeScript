  cp = require 'child_process'
  path = require 'path'
  fs = require 'fs'
  sh = require 'execSync'

  # configuration for building TMEPlatformAgent solution
  devenv = "C:\\Program Files (x86)\\Microsoft Visual Studio 9.0\\Common7\\IDE\\devenv.com"
  msbuild = "C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\MSBuild.exe"
  vstest = "C:\\Program Files (x86)\\Microsoft Visual Studio 12.0\\Common7\\IDE\\CommonExtensions\\Microsoft\\TestWindow\\vstest.console.exe"
  svnRoot = "C:\\SVN\\HubDataServices\\Trunk"
  tmePlatformAgentRelativePath = "Platforms\\TME\\PlatformAgent"
  releaseShareAddress = "\\\\fas3000-b.chn.agilent.com\\v6\\WCSS_Eng_STE\\TME_EXTRACTOR\\SOFTWARES"
  archiveTmePlatformAgentSharedAddress = path.join(releaseShareAddress, "TMEPlatformAgent")

  solutionFolderName = "TmePlatformAgentWin7"
  integrationTestSolutionDir = "TmePlatformAgent.IntegrationTest"
  solutionName = solutionFolderName + ".sln"
  setupProjectFolderName = "TMEPlatformAgentSetup"
  setupProjectName = setupProjectFolderName + ".vdproj"
  msiName = "TMEPlatformAgent.msi"
  releaseNoteFileName = "ReleaseNote.txt"

  solutionFullPath = path.join(svnRoot, tmePlatformAgentRelativePath,
                               solutionFolderName, solutionName)
  setupProjectFullPath = path.join(svnRoot, tmePlatformAgentRelativePath,
                                   setupProjectFolderName, setupProjectName)
  msiFullPath = path.join(svnRoot, tmePlatformAgentRelativePath,
                          setupProjectFolderName, "Debug", msiName)
  integrationTestSolutionFullPath = path.join(svnRoot,
  				tmePlatformAgentRelativePath, integrationTestSolutionDir,
  				integrationTestSolutionDir + ".sln")
  integrationTestDll = path.join(svnRoot, tmePlatformAgentRelativePath,
                integrationTestSolutionDir, integrationTestSolutionDir,
                "bin\\x86\\Debug", integrationTestSolutionDir + ".dll")
  version = "0.0.0"

  exports.getVersion = (project, callback)->
      # version information is in project.vdproj file.
      # "ProductVersion" = "8:2.1.1"
      content = fs.readFileSync(project)
      lines = content.toString().split('\n')

      versionPattern = /\"ProductVersion\" = \"8:([0-9].[0-9].[0-9])\"/
      lines.forEach (line)->
          match = line.match versionPattern
          if match
              callback match[1].toString()

  exports.run = (command, verbose)->
      console.log command
      result = sh.exec(command)

      if ! result.code
          if verbose
              console.log result.stdout
          return true
      else
          console.log result.stdout
          console.log result.stderr
          return false

  exports.CopyReleaseNote = ()->
      # copy ReleaseNote to shared folder.
    sourceReleaseNote = path.join(svnRoot, tmePlatformAgentRelativePath, "TMEPlatformAgent", releaseNoteFileName)
    targetReleaseNote = path.join(releaseShareAddress, releaseNoteFileName)

    command = "copy /Y /V #{sourceReleaseNote} #{targetReleaseNote}"
    console.log('Copying ReleaseNote.txt to shared folder ...')
    @run(command)

  exports.update = ()->
      tmePlatformAgentPath = path.join(svnRoot,  "Platforms\\TME")

      # revert any local changes.
      console.log "";
      console.log "Reverting any local changes ..."
      command = "svn revert -R -q #{tmePlatformAgentPath}"
      @run(command, true)

      # Update source code calling svn command.
      console.log ""
      console.log "Updating source code from SVN ..."
      command = "svn update #{tmePlatformAgentPath}"
      @run(command, true)

  exports.archive = ()->
      # archive old TMEPlatformAgent setup package.
      console.log ""
      console.log 'archiving old TMEPlatformAgent package to ' + archiveTmePlatformAgentSharedAddress
      allItem = fs.readdirSync(releaseShareAddress)
      allItem.forEach (item)->
          if fs.statSync(path.join(releaseShareAddress, item)).isDirectory()
              return

          match = item.match /TMEPlatformAgent_([0-9].[0-9].[0-9]).msi/
          if ! match
              return

          if match[1] == version
              return

          target = path.join(archiveTmePlatformAgentSharedAddress, path.basename(item))
          command = "move /Y #{path.join(releaseShareAddress, item)} #{target}"
          console.log command
          sh.exec(command)


  # compile TMEPlatformAgentWin.sln solution.
  exports.compile = ()->
      console.log ""
      console.log "Compiling #{solutionName} ..."
      command = "\"#{devenv}\" #{solutionFullPath} /Rebuild Debug x86"
      console.log command
      @run(command)


  # build TMEPlatformAgentSetup.msi package
  exports.build = ()->
      # no need to compile solution first because we are calling
      # this project through solution.
      console.log ""
      console.log "Building #{msiName} ..."
      command = "\"#{devenv}\" #{solutionFullPath} /Project #{setupProjectFullPath} /Rebuild Debug x86"
      @run(command)

  # execute Integration Test
  exports.runTestCases = ()->
      console.log ""
      console.log "Executing integration test cases ..."
      # We can try "/inIsolation" test option.
      command = "\"#{vstest}\" /InIsolation /Platform:x86 #{integrationTestDll}"
      @run(command)

  # for developing this script purpose
  exports.develop = ()->
      # try if not
      success = false

      if not success
          console.log "hit it."

      # exit without executing below commands
      console.log 'will exit immediately ...'
      process.exit()

      console.log "developing this script ..."
      success = -999
      success = @runTestCases()

      console.log "success result is: #{success}"

  # release TMEPlatformAgentSetup_<version>.msi to \\fas3000.
  exports.release = ()->
      # Update source code
      @update()

      # need to execute build at least
      success = false
      success = @build()

      if not success
          console.log "Building TMEPlatformAgent.sln is failed. Can't proceed."

      # get version first.
      # it might use 0.0x seconds.
      @getVersion(setupProjectFullPath, (versionNumber)->
          version = versionNumber
          )

      # delay 100ms to wait for async call getVersion to
      # assign value to version variable.
      setTimeout(
                 ()->
                  a = 100
              , 100
          )

      # build VS2013 Integration Test Solution
      success = false
      success = @buildTestCases()

      if not success
          console.log "Build integration test case solution failed. Can't proceed."
          process.exit()

      # Execute VS2013 Integration Test Cases
      success = false
      success = @runTestCases()

      if not success
          console.log "Integration Test failed, release stopped."
          process.exit()

      # append version number behand setup package name
      # to make it like TMEPlatformAgentSetup_2.0.0.msi
      source = msiFullPath

      targetName = msiName.replace(".msi", "_#{version}.msi")
      target = path.join(releaseShareAddress, targetName)
      # copy it to shared folder for releasing.
      command = "copy /Y /V #{source} #{target}"
      @run(command)
      # archive previous TMEPlatformAgent_*.msi except new copied one.
      @archive()

      # copy ReleaseNote.txt to shared folder
      @CopyReleaseNote()

  # build VS2013 Integration Test Case Solution
  exports.buildTestCases = ()->
      console.log ""
      console.log "Building VS2013 integration test cases solution ..."
      command = "\"#{msbuild}\" #{integrationTestSolutionFullPath} /t:Rebuild /p:Configuration=Debug;Platform=x86"
      @run(command)

  # print help information for user to use this script.
  exports.help = ()->
      console.log "CRS TME Extractor Distribution Script"
      console.log "This script is written by Node.js by Nixin Wang."
      console.log "Below individual commands are available for your usage:"
      console.log ""
      console.log "update: will update SVN\\HubDataServices\\Trunk\\Platforms\\TME directory."
      console.log "build: will call VS2008 devevn to build TmePlatformAgent.sln."
      console.log "buildTest: will call msbuild to build VS2013 integrqation test cases solution."
      console.log "test: will call vstest.console.exe to execute VS2013 integration test cases."
      console.log "dev: will execute steps defined in 'develop()' module for develop this script purpose."
      console.log ""
      console.log "release: will run 'update', 'build', 'buildTest', 'test' and finally release setup package to fas3000-b shared folder."
      console.log "not implemented includes 'dist: distribute to TSPM server', 'branch: create branch for source code'"
      console.log ""
      console.log "Example: coffee tmeRelease.coffee release"

  # TODO: distribute TMEPlatformAgentSetup to TSPM
  # and Lighthouse software download web page.
  exports.distribute = ()->
      console.log 'distributing ' + solutionName

  # TODO: once we have a release, we should branch it
  # on svn.
  # from: C:\SVN\HubDataServices\Trunk\Platforms\TME
  # to  : C:\SVN\HubDataServices\Trunk\Platforms\Releases\TMEPlatformAgent_2_1_8
  # then we need to update FunctionTest project references.
  exports.branch = ->
      console.log 'branch source code ...'

  action = process.argv[2]
  switch action
      when 'compile' then @compile()
      when 'build' then @build()
      when 'buildTest' then @buildTestCases()
      when 'release' then @release()
      when "test" then @runTestCases()
      when 'dist', 'distribute' then @distribute()
      when 'update' then @update()
      when 'dev' then @develop()
      when 'help' then @help()
      else
          console.log('unknown action: ' + action)
          console.log('Action choice: compile, build, release, dist/distribute')
