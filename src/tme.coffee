TmeRelease = require './TmeRelease'

command = process.argv[2]
manager = new TmeRelease()
manager.execute command
