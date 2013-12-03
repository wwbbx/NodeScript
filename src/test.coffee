fs = require 'fs'
util = require 'util'

item = "\\\\polarbear.chn.agilent.com\\H$\\Data\\ActivityLog\\ActivityLog_24BRSTE81_20121018030101"
stat = fs.statSync(item)

console.log "\\" + stat.mtime.getFullYear() + "\\"
console.log "\\" + stat.mtime.getMonth() + "\\"
