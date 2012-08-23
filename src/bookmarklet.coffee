###
jslint-github
Copyright(c) 2012 Pedro Fuentes <code@pedrofuent.es>
MIT Licensed
###

class JSlintGitHub
  constructor: (options) ->
    @options =
      diffSelector: $ '#diff .actions a[href$="js"]'
      fileSelector: $ '#files #raw-url[href$="js"]'
      jslint:
        maxerr    : 60
    
    $.extend @options, options if options?

    @findType()
    @findFiles()
  
  checkFiles: ->
    $.each @files, (index, val) =>
      @getFile val

  findDiffNumber: (element) ->
    diffId      = $(element).closest('[id*="diff-"]').attr "id"
    @diffNumber = diffId.replace "diff-", ""

  findNumberForDiff: (number) ->
    element = $ "#L#{@diffNumber}R#{number}"
    if $.trim(element.text()) isnt "..." then element else []

  findNumberForFile: (number) ->
    $ ".line_numbers #L#{number}"

  findFiles: ->
    @files = if @type is 'diff' then @options.diffSelector else @options.fileSelector

  findLineNumber: (number) ->
    if @type is 'diff' then @findNumberForDiff number else @findNumberForFile number

  findType: ->
    @type = if @options.diffSelector.length > 0 then 'diff' else if @options.fileSelector.length > 0 then 'file' else false

  getFile: (element) ->
    $.get @getUrl(element), (data) =>
      @testQuality element, data

  getUrl: (element) ->
    if @type is 'diff' then $(element).attr('href').replace 'blob', 'raw' else $(element).attr 'href'

  setTooltip: (lineNumber, character, reason) ->
    title      = lineNumber.attr('title') || ''

    lineNumber.attr 'title', "#{title}<div style=\"text-align:left;\">char(#{character}) #{reason}</div>"

    lineNumber
      .attr('style', 'color:red;')
      .tipsy
        gravity: $.fn.tipsy.autoNS,
        html: true

  showErrors: (element) ->
    @findDiffNumber element if @type is 'diff'

    $.each JSLINT.data().errors, (index, val) =>
      if val
        lineNumber = @findLineNumber val.line

        if lineNumber.length > 0
          @setTooltip lineNumber, val.character, val.reason

  testQuality: (element, data) ->
    JSLINT data, @options.jslint
    @showErrors element

JSlinter = new JSlintGitHub()
JSlinter.checkFiles()