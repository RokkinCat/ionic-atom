exec = require("child_Process").exec
module.exports = ->
  exec("ionic serve --nobrowser")
