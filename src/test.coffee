sh = require 'execSync'

result = sh.exec('dir c:\\temp')
console.log result.stdout
console.log 'command finished.'
