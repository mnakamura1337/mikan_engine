class VM
  constructor: (@program) ->
    @ip = 0
    @mem = {}
    @layers = {}
    @loadSettings()

    @labelMap = {}
    for op, i in @program.script
      if op.label
        @labelMap[op.label] = i

    @detectAvailableOptions()
    @setupHTML()
    @activateSettings()

    return null

  settingsKey: ->
    "vn_settings_#{@program.meta.id}"

  loadSettings: ->
    @settings = JSON.parse(localStorage.getItem(@settingsKey())) || {
      'bilingual': false,
      'langCharNames': @program.meta.orig_lang,
      'lang1': @program.meta.orig_lang,
      'lang2': 'en',
      'screenMode': 'w'
    }

  saveSettings: ->
    localStorage.setItem(@settingsKey(), JSON.stringify(@settings))

  activateSettings: ->
    VM.resizeWindowHandler(@)
    if @settings.bilingual
      document.getElementById('text_window_full').style.display = 'none';
      document.getElementById('text_window_lang1').style.display = 'block';
      document.getElementById('text_window_lang2').style.display = 'block';
    else
      document.getElementById('text_window_full').style.display = 'block';
      document.getElementById('text_window_lang1').style.display = 'none';
      document.getElementById('text_window_lang2').style.display = 'none';

  detectAvailableOptions: ->
    @possible = {}

    # Collect character names languages
    langCharNames = {}
    for k, char of @program.chars
      for langName, charName of char.name
        langCharNames[langName] = 1
    @possible.langCharNames = []
    for langName, v of langCharNames
      @possible.langCharNames.push(langName)

  setupHTML: ->
    @storyWindow = $('#story_window')
    if @storyWindow.length == 0
      throw "engine init: unable to find story_window"
    @storyWindow.html('''
      <div id="game_window"></div>
      <div id="text_window">
        <div id="menu_frame"></div>
        <div id="text_window_bg"></div>
        <div id="text_window_header"></div>
        <div id="text_window_full"></div>
        <div id="text_window_lang1"></div>
        <div id="text_window_lang2"></div>
        <button id="go_button" onclick="vm.iterate();">Go</button>
        <button id="settings_button" onclick="vm.settingsDialog();">Settings</button>
      </div>
      ''')
    vm = @
    $(window).resize (ev) -> VM.resizeWindowHandler(vm)

  @resizeWindowHandler: (vm) ->
    if vm.settings['screenMode'] == 'z'
      z1 = $(window).height() / vm.program.meta.resolution.h
      z2 = $(window).width() / vm.program.meta.resolution.w
      console.log("window resized: ", z1, z2)
      vm.storyWindow[0].style.zoom = if z1 < z2 then z1 else z2
    else
      vm.storyWindow[0].style.zoom = 1

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

  settingsDialog: ->
    $('#settings_button').prop('disabled', true)
    tw = $('#text_window');

    langCharNamesOpts = @generateOptions(@possible.langCharNames, @settings['langCharNames'])
    lang1Opts = @generateOptions(@possible.langCharNames, @settings['lang1'])
    lang2Opts = @generateOptions(@possible.langCharNames, @settings['lang2'])

    tw.append('''
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
    form.screenMode.value = @settings['screenMode']

    vm = @
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

  iterate: ->
    loop
      op = @program.script[@ip]
      console.log(@ip, op)
      @ip++
      opName = op.op

      switch opName
        when 'wait'
          setTimeout(window.vm.iterate.bind(window.vm), op.t)
          return
        when 'keypress'
          return
        when 'menu_run'
          Opcodes.menu_run(op, this)
          return
        else
          func = Opcodes[opName]
          if func
            mustContinue = func(op, this)
            if !mustContinue
              return
          else
            console.error("IP=#{@ip}: invalid opcode '#{opName}'")
            return

    return null

  jmp: (label) ->
    addr = @labelMap[label]
    if (addr)
      @ip = addr
    else
      throw "jump: label \"#{label}\" not found"

  convertFileName: (fn) ->
    @program.meta.asset_path + "/" + fn.replace(/\\/g, '/')

  showTextInElement: (el, txt, op, lang) ->
    el.innerHTML = switch op
      when 'say'
        switch lang
          when 'en' then "“#{txt}”"
          when 'ja' then "「#{txt}」"
          when 'ru' then "— #{txt}"
          else "❮#{txt}❯"
      when 'think'
        switch lang
          when 'ja' then "（#{txt}）"
          else "(#{txt})"
      else
        txt

  showText: (charName, textColor, txt, op) ->
    # Make sure that textColor is properly deleted: it must be "null",
    # not just "undefined" to reset style
    if !(textColor?)
      textColor = null

    char_name_el = document.getElementById('text_window_header')
    console.log("textColor = ", textColor)
    char_name_el.style.color = textColor
    char_name_el.innerHTML = if charName
      charName[@settings.langCharNames]
    else
      ''

    if @settings.bilingual
      e1 = document.getElementById('text_window_lang1')
      e1.style.color = textColor
      @showTextInElement(e1, txt[@settings.lang1], op, @settings.lang1)

      txt_en_el = document.getElementById('text_window_lang2')
      txt_en_el.style.color = textColor
      if txt.en
        @showTextInElement(txt_en_el, txt.en, op, 'en')
      else
        txt_en_el.innerHTML = "<div class='preloader'><img src='preloader.gif'></div>"
        tmp_vm = @
        translateYandex txt.ja, 'ja-en', (trans_txt) ->
          tmp_vm.showTextInElement(txt_en_el, trans_txt, op, 'en')
    else
      el = document.getElementById('text_window_full')
      el.style.color = textColor
      @showTextInElement(el, txt[@settings.lang1], op, @settings.lang1)

  memEval: (expr) ->
    `var _t; with (this.mem) { _t = eval(expr) }`
    return _t

  @getLayer: (id) ->
    elId = "layer_#{id}"
    el = document.getElementById(elId)
    return el if el

    layerEl = document.createElement('div')
    layerEl.id = elId
    layerEl.className = 'layer'

    document.getElementById('game_window').appendChild(layerEl)
    return layerEl

  @setLayerZ: (el, id, z) ->
    el.style.zIndex = if z == undefined
      if id == 'bg' then 0 else 5
    else
      z

  @getAudio: (id) ->
    elId = "audio_#{id}"
    el = document.getElementById(elId)
    return el if el

    audioEl = document.createElement('audio')
    audioEl.id = elId

    document.body.appendChild(audioEl)
    return audioEl

  composeToCanvas: (imgs, onSuccess) ->
    processImages = ->
      loaded += 1
      if loaded < maxLoad
        return
      canvas = document.createElement('canvas')
      canvas.width = imgArr[0].width
      canvas.height = imgArr[0].height
      canvas.style.position = 'absolute';
      canvas.style.top = '0px';
      canvas.style.left = '0px';
      ctx = canvas.getContext('2d')
      i = 0
      while i < maxLoad
        ctx.drawImage imgArr[i], imgs[i].px, imgs[i].py
        i++
      # var t2 = window.performance.now();
      # console.log(t2 - t1);
      onSuccess canvas
      return

    # t1 = window.performance.now()
    maxLoad = imgs.length
    loaded = 0
    imgArr = new Array(maxLoad)

    i = 0
    while i < maxLoad
      imgEl = new Image
      imgArr[i] = imgEl
      imgEl.onload = processImages
      imgEl.src = @convertFileName(imgs[i].fn)
      i++
    return

  getOriginAdj: (layerId, layer, newFn) ->
    adj = {x: 0, y: 0}

    if newFn and newFn[0] == '#'
      composeImgId = newFn.substring(1)
      composeImg = @program.imgs[composeImgId]
      adj = {x: composeImg.ox, y: composeImg.oy}
    else if vm.layers[layerId]?
      layerSpec = vm.layers[layerId]
      if layerSpec.compositeImg?
        composeImg = layerSpec.compositeImg
        adj = {x: composeImg.ox, y: composeImg.oy}

    console.log("asked for #{layerId}, newFn = #{newFn} -> adj = ", adj)

    return adj

  class Opcodes
    @jmp: (inst, vm) ->
      vm.jmp(inst.dest)
      return true

    @jmp_if: (inst, vm) ->
      res = vm.memEval(inst.expr)
      console.log(res)
      vm.jmp(inst.dest) if res
      return true

    @var_set: (inst, vm) ->
      res = vm.memEval(inst.expr)
      console.log(res)
      vm.mem[inst.var] = res
      return true

    @clear: (inst, vm) ->
      $("#game_window").html('')
      return true

    @img: (inst, vm) ->
      layer = VM.getLayer(inst.layer)
      adj = vm.getOriginAdj(inst.layer, layer, inst.fn)

      layer.style.left = "#{inst.x - adj.x}px" if inst.x?
      layer.style.top = "#{inst.y - adj.y}px" if inst.y?
      layer.style.opacity = inst.a if inst.a?
      VM.setLayerZ(layer, inst.layer, inst.z) if inst.z?

      if inst.fx?
        if inst.fx.blur?
          layer.style.webkitFilter = "blur(#{inst.fx.blur}px)"
          layer.style.filter = "blur(#{inst.fx.blur}px)"

      if inst.fn == undefined
        # do nothing with the contents
        return true
      else if inst.fn == ''
        # remove contents
        layer.innerHTML = ''
        delete vm.layers[inst.layer]
        return true
      else if inst.fn[0] == '#'
        composeImgId = inst.fn.substring(1)
        composeImg = vm.program.imgs[composeImgId]
        if composeImg
          vm.composeToCanvas composeImg.imgs, (canvas) ->
            layer.innerHTML = ''
            layer.appendChild(canvas)
            vm.iterate()
          vm.layers[inst.layer] = {compositeImg: composeImg}
          return false # VM will continue after composeToCanvas will finish
        else
          throw "img: invalid composite image \"#{inst.fn}\" requested"
      else
        layer.innerHTML = "<img src='#{vm.convertFileName(inst.fn)}' />";
        vm.layers[inst.layer] = {}
        return true

    @anim: (inst, vm) ->
      layer = VM.getLayer(inst.layer, inst.z)
      adj = vm.getOriginAdj(inst.layer, layer, inst.fn)

      toward = {}
      toward.left = "#{inst.x - adj.x}px" if inst.x?
      toward.top = "#{inst.y - adj.y}px" if inst.y?
      toward.left = "#{$(layer).position().left + inst.dx}px" if inst.dx?
      toward.top = "#{$(layer).position().top + inst.dy}px" if inst.dy?

      if inst.fn?
        # having alternative filename means that we need to operate on two different images
        if layer.children.length != 1
          throw "anim: about to start image transfade, but layer has #{layer.children.length} images in it"
        oldImg = layer.children[0]
        composeImgId = inst.fn.substring(1)
        composeImg = vm.program.imgs[composeImgId]
        if composeImg
          vm.composeToCanvas composeImg.imgs, (newImg) ->
            newImg.style.opacity = 0
            layer.appendChild(newImg)
            t = inst.t || 500

            $(layer).animate(toward, t)
            $(newImg).animate({opacity: 1}, t / 2, 'linear', ->
              $(oldImg).animate({opacity: 0}, t / 2, 'linear')
            )

            setTimeout((-> layer.removeChild(oldImg)), t + 10)
            vm.iterate()
          vm.layers[inst.layer] = {compositeImg: composeImg}
          return false # VM will continue after composeToCanvas will finish
        else
          throw "anim: transfade to non-compose img not implemented yet"
      else
        toward.opacity = inst.a if inst.a?
        console.log("anim: layer=", layer, " toward=", toward)
        $(layer).animate(toward, inst.t || 500)
        true

    @narrate: (inst, vm) ->
      vm.showText(null, null, inst.txt, inst.op)
      true

    @say: (inst, vm) ->
      char = vm.program.chars[inst.char]
      char = inst.char unless char
      vm.showText(char.name, char.color, inst.txt, inst.op)

      if inst.voice
        voice_el = VM.getAudio('voice')
        voice_el.src = vm.convertFileName(inst.voice)
        voice_el.loop = false
        voice_el.volume = 1
        voice_el.play()

      true

    @think: (inst, vm) -> Opcodes.say(inst, vm)

    @sound_play: (inst, vm) ->
      el = VM.getAudio(inst.channel)
      el.src = vm.convertFileName(inst.fn)
      el.loop = inst.loop || false
      el.volume = 0.3
      el.play()
      true

    @sound_stop: (inst, vm) ->
      el = VM.getAudio(inst.channel)
      el.src = ""
      true

    @menu_add: (inst, vm) ->
      vm.mem['menu_items'] ||= []
      vm.mem.menu_items.push({'txt': inst.txt, 'code': inst.code})
      true

    @menu_run: (inst, vm) ->
      menu_el = $('#menu_frame')
      t = ""
      for item in vm.mem.menu_items
        t += "<p><button class=\"menu_item\" data-code=\"#{item.code}\">#{item.txt[vm.settings.lang1]}</button></p>"

      menu_el.html(t)

      $(".menu_item").click (ev) ->
        vm.mem['menu_result'] = $(ev.target).data('code')
        delete vm.mem['menu_items']
        menu_el.hide()
        vm.iterate()

      menu_el.show()

window.vm = new VM(window.program)
window.vm.iterate()
