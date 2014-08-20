{$, ScrollView, View, Task, File} = require 'atom'
url = require "url"
http = require("http")


class WebBrowserPreviewView extends ScrollView
  @content: (params) ->
    @iframe outlet: "frame", class: "iphone", src: params.url, sandbox: "none"
  getTitle: ->
    "Ionic: Preview"
  initialize: (params) ->
    me = $(@)
    @url = params.url
    @.on 'load', ->
      $(window).on 'resize',  ->
        height = me[0].parentNode?.scrollHeight
        if height? and height < me.height()
          me.css("transform", "scale(" + ((height - 100) / me.height()) + ")")
        else
          me.css("transform", "none")

  go: ->
    me = $(@)
    @.src = @url
    height = me[0].parentNode?.scrollHeight
    if height? and height < me.height()
      me.css("transform", "scale(" + ((height - 100) / me.height()) + ")")
    else
      me.css("transform", "none")

    me.css("display", "block")



module.exports =
  activate: ->
    atom.workspaceView.command "ionic:preview", =>
      atom.workspace.open "ionic://localhost:8100", split: "right"

    atom.workspace.registerOpener (uri) ->
      try
        {protocol, host, pathname} = url.parse(uri)
      catch
        return

      return unless protocol is "ionic:"

      uri = url.parse(uri)
      uri.protocol = "http:"

      preview = new WebBrowserPreviewView(url: uri.format())

      http.get(uri.format(), ->
        preview.go()
        atom.workspace.activateNextPane()
      ).on('error', ->
        atom.workspace.destroyActivePaneItem()
        alert("You have to start the ionic server first!")
      )

      return preview
