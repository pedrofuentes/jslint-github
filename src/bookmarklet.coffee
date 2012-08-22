###
jslint-github
Copyright(c) 2012 Pedro Fuentes <code@pedrofuent.es>
MIT Licensed
###

class JSlintGitHub
  constructor: ->
    @diffSelector = $ '#diff .actions a[href$="js"]'
    @fileSelector = $ '#files #raw-url[href$="js"]'
    @findType()
    @findFiles()
  
  checkFiles: ->
    $.each @files, (index, val) =>
      @getFile @getUrl val

  findFiles: ->
    @files = if @type is 'diff' then @diffSelector else @fileSelector

  findLine: (element, number) ->
    file = $(element).parent().parent().parent().parent()
    if @type is 'diff' then file.find "[data-remote*=\"line=#{number}\"]" else file.find "#L#{number}"

  findLineNumber: (element, number) ->
    #TODO: Find number for @type file
    if @type is 'diff' then element.parent().parent().find('.line_numbers').eq 1 else element.parent().parent().parent().parent().find ".line_numbers #L#{number}"

  findType: ->
    @type = if @diffSelector.size() > 0 then 'diff' else if @fileSelector.size() > 0 then 'file' else false

  getFile: (url) ->
    $.get url, (data) =>
      @testQuality data

  getUrl: (element) ->
    if @type is 'diff' then $(element).attr('href').replace 'blob', 'raw' else $(element).attr 'href'

  setTooltip: (element, number, character, reason) ->
    lineNumber = @findLineNumber element, number
    title      = lineNumber.attr('title') || ''

    lineNumber.attr 'title', "#{title}<div style=\"text-align:left;\">char(#{character}) #{reason}</div>"

    lineNumber
      .attr('style', 'color:red;')
      .tipsy
        gravity: $.fn.tipsy.autoNS,
        html: true

  showErrors: ->
    element = if @type is 'diff' then @diffSelector else @fileSelector
    $.each JSLINT.data().errors, (index, val) =>
      if val
        line = @findLine element, val.line

        if line.size() > 0
          @setTooltip line, val.line, val.character, val.reason

  testQuality: (data) ->
    JSLINT data
    @showErrors()

JSlinter = new JSlintGitHub();
JSlinter.checkFiles();