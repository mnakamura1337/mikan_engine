all: \
	style_800x600.css \
	style_960x540.css \
	style_1280x720.css \
	vm.js

vm.js: vm.coffee
	coffee -c vm.coffee

%.css: %.scss
	scss $< $@

style_800x600.scss: default.scss
	rm -f $@.tmp
	echo '$$game_w: 800px;' >>$@.tmp
	echo '$$game_h: 600px;' >>$@.tmp
	cat default.scss >>$@.tmp
	mv $@.tmp $@

style_960x540.scss: default.scss
	rm -f $@.tmp
	echo '$$game_w: 960px;' >>$@.tmp
	echo '$$game_h: 540px;' >>$@.tmp
	cat default.scss >>$@.tmp
	mv $@.tmp $@

style_1280x720.scss: default.scss
	rm -f $@.tmp
	echo '$$game_w: 1280px;' >>$@.tmp
	echo '$$game_h: 720px;' >>$@.tmp
	cat default.scss >>$@.tmp
	mv $@.tmp $@
