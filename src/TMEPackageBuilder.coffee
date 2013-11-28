class TmePackageBuilder
    # class to update source code and build TMEPlatformAgent package

    # CoffeeScript align @ to this.
    # below line is equal to this.devenvCommand:""
    @devenvCommand : ""

    useDevenvVersion:(version)->
        # switch to use different devenv.com version
        @devenvCommand = "C:\\Program Files (x86)\\Microsoft Visual Studio #{version}\\Common7\\IDE\\devenv.com"

    updateSourceCode: ()->
        # update source code using svn.

    buildSolution: (solution)->
        # build TMEPlatformAgent solution

    cleanSolution: (solution) ->
        # clean up given solution

module.exports = TmePackageBuilder