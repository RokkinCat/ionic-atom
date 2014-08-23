{$, ScrollView, View, Task, File} = require 'atom'
url = require "url"
http = require("http")


class WebBrowserPreviewView extends ScrollView
  @content: (params) ->
    @iframe outlet: "frame", class: params.platform, src: params.url, sandbox: "none"
  getTitle: ->
    "Ionic: Preview" + @platform
  initialize: (params) ->
    me = $(@)
    @url = params.url
    @platform = params.platform
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
    me = $(@)
    me.platform = 'iphone-5'
    atom.workspaceView.command "ionic:preview-iPhone-5", =>
      me.platform = 'iphone-5'
      atom.workspace.open "ionic://localhost:8100", split: "right"
    atom.workspaceView.command "ionic:preview-moto-x", =>
      me.platform = 'moto-x'
      atom.workspace.open "ionic://localhost:8100", split: "right"

    atom.workspace.registerOpener (uri) ->
      try
        {protocol, host, pathname} = url.parse(uri)
      catch
        return

      return unless protocol is "ionic:"

      uri = url.parse(uri)
      uri.protocol = "http:"

      preview = new WebBrowserPreviewView(url: uri.format(), platform: me.platform)

      http.get(uri.format(), ->
        preview.go()
        atom.workspace.activateNextPane()
      ).on('error', ->
        atom.workspace.destroyActivePaneItem()
        alert("You have to start the ionic server first!")
      )

      return preview
