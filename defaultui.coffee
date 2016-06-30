class DefaultUI
  constructor: (@vm) ->
    @detectAvailableOptions()

    return null

  detectAvailableOptions: ->
    @possible = {}

    # Collect character names languages
    langCharNames = {}
    for k, char of @vm.program.chars
      for langName, charName of char.name
        langCharNames[langName] = 1
    @possible.langCharNames = []
    for langName, v of langCharNames
      @possible.langCharNames.push(langName)

  setupHTML: ->
    @textWindow = $('#text_window')
    @textWindow.append('''
      <button id="go_button">Go</button>
      <button id="settings_button">Settings</button>
      <button id="history_button">History</button>
    ''')

    ui = @
    $('#go_button').click -> ui.vm.iterate()
    $('#settings_button').click -> ui.settingsDialog()
    $('#history_button').click -> ui.historyDialog()

  settingsDialog: ->
    $('#settings_button').prop('disabled', true)

    langCharNamesOpts = @generateOptions(@possible.langCharNames, @vm.settings['langCharNames'])
    lang1Opts = @generateOptions(@possible.langCharNames, @vm.settings['lang1'])
    lang2Opts = @generateOptions(@possible.langCharNames, @vm.settings['lang2'])

    @textWindow.append('''
      <div id="settings_dialog">
      <form id="settings_dialog_inner">
      <h1>Settings</h1>
      <h2>Languages</h2>
      <label>
        Character names:
        <select name="langCharNames" id="s_lang_char_names"></select>
      </label>
      <label>
        Primary text:
        <select name="lang1" id="s_lang1"></select>
      </label>
      <label>
        Secondary text:
        <select name="lang2" id="s_lang2"></select>
      </label>
      <h2>Screen</h2>
      <label><input type="radio" name="screenMode" value="w">Windowed</label>
      <label><input type="radio" name="screenMode" value="z">Windowed, autozoom</label>
      <p>
        <button id="settings_ok">OK</button>
        <button id="settings_cancel">Cancel</button>
      </p>
      </form>
      </div>
      ''')

    form = $('#settings_dialog_inner')[0]
    $('#s_lang_char_names').html(langCharNamesOpts)
    $('#s_lang1').html(lang1Opts)
    $('#s_lang2').html(lang2Opts)
    form.screenMode.value = @vm.settings['screenMode']

    vm = @vm
    $('#settings_ok').click ->
      vm.settings.langCharNames = form.langCharNames.value
      vm.settings.lang1 = form.lang1.value
      vm.settings.lang2 = form.lang2.value
      vm.settings.screenMode = form.screenMode.value
      vm.saveSettings()
      vm.activateSettings()
      $('#settings_dialog').remove()
      $('#settings_button').prop('disabled', false)
      false
    $('#settings_cancel').click ->
      $('#settings_dialog').remove()
      $('#settings_button').prop('disabled', false)
      false

  historyDialog: ->
    @textWindow.append('''
      <div id="history_dialog">
        <div id="history_area">
        </div>
      <p>
        <button id="history_ok">OK</button>
      </p>
      </div>
      ''')

    ha = $('#history_area')
    @historyPopulate(ha)
    ha.scrollTop(1e10)

    $('#history_ok').click ->
      $('#history_dialog').remove()
      false

  historyPopulate: (cnt) ->
    s = ""
    lang = @vm.settings.lang1
    @seen.foreach (i) ->
      op = @vm.program.script[i]
      switch op.op
        when 'say', 'think', 'narrate'
          s += '<div class="entry">'
          chName = if op.char
            @vm.program.chars[op.char].name[lang]
          else
            ''
          s += "<div class=\"char\">#{chName}</div>"
          s += "<div class=\"txt\">#{VM.textInElement(op.txt[lang], op.op, lang)}</div></div>\n"

    cnt.html(s)

    return null

  # Helper to generate HTML options from an array + currently selected
  # element
  generateOptions: (arr, current) ->
    r = ''

    for el in arr
      r += "<option value=\"#{el}\""
      if el == current
        r += " selected"
      r += ">#{el}</option>"

    return r
