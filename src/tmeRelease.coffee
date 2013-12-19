  cp = require 'child_process'
  path = require 'path'
  fs = require 'fs'
  sh = require 'execSync'

  # configuration for building TMEPlatformAgent solution
  devenv = "C:\\Program Files (x86)\\Microsoft Visual Studio 9.0\\Common7\\IDE\\devenv.com"
  svnRoot = "C:\\SVN\\HubDataServices\\Trunk"
  tmePlatformAgentRelativePath = "Platforms\\TME\\PlatformAgent"
  releaseShareAddress = "\\\\fas3000-b.chn.agilent.com\\v6\\WCSS_Eng_STE\\TME_EXTRACTOR\\SOFTWARES"
  archiveTmePlatformAgentSharedAddress = path.join(releaseShareAddress, "TMEPlatformAgent")

  solutionFolderName = "TmePlatformAgentWin7"
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
      # Update source code calling svn command.
      tmePlatformAgentPath = path.join(svnRoot,  "Platforms\\TME")
      command = "svn update #{tmePlatformAgentPath}"
      @run(command, true)

  exports.archive = ()->
      # archive old TMEPlatformAgent setup package.
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
      console.log "Compiling #{solutionName} ..."
      command = "\"#{devenv}\" #{solutionFullPath} /Rebuild Debug x86"
      console.log command
      @run(command)


  # build TMEPlatformAgentSetup.msi package
  exports.build = ()->
      # no need to compile solution first because we are calling
      # this project through solution.
      console.log "Building #{msiName} ..."
      command = "\"#{devenv}\" #{solutionFullPath} /Project #{setupProjectFullPath} /Rebuild Debug x86"
      @run(command)


      # TODO: make sure TMEPlatformAgent.msi is the latest.

  # release TMEPlatformAgentSetup_<version>.msi to \\fas3000.
  exports.release = ()->
      # need to execute build at least
      success = @build()

      #success = true

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

      if success
          console.log 'build success'
      else
          console.log 'build is failed. please use VS2008 IDE to correct errors.'

      # append version number behand setup package name
      # to make it like TMEPlatformAgentSetup_2.0.0.msi
      source = msiFullPath

      targetName = msiName.replace(".msi", "_#{version}.msi")
      target = path.join(releaseShareAddress, targetName)
      # copy it to shared folder for releasing.
      command = "copy /Y /V #{source} #{target}"
      @run(command)
      # copy ReleaseNote.txt to shared folder
      # @CopyReleaseNote()
      # archive previous TMEPlatformAgent_*.msi except new copied one.
      @archive()

  # distribute TMEPlatformAgentSetup to TSPM
  # and Lighthouse software download web page.
  exports.distribute = ()->
      console.log 'distributing ' + solutionName

  action = process.argv[2]
  switch action
      when 'compile' then @compile()
      when 'build' then @build()
      when 'release' then @release()
      when 'dist', 'distribute' then @distribute()
      when 'update' then @update()
      else
          console.log('unknown action: ' + action)
          console.log('Action choice: compile, build, release, dist/distribute')
