COFFEE_SRCS=\
	rangeset.coffee \
	vm.coffee

all: \
	style_640x480.css \
	style_800x600.css \
	style_960x540.css \
	style_1280x720.css \
	style_1280x720_f280x280.css \
	vm.js

vm.js: $(COFFEE_SRCS)
	cat $(COFFEE_SRCS) | coffee -c --stdio >$@.tmp
	mv $@.tmp $@

%.css: %.scss
	scss $< $@

style_640x480.scss: default.scss
	rm -f $@.tmp
	echo '$$game_w: 640px;' >>$@.tmp
	echo '$$game_h: 480px;' >>$@.tmp
	cat default.scss >>$@.tmp
	mv $@.tmp $@

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

style_1280x720_f280x280.scss: default.scss
	rm -f $@.tmp
	echo '$$game_w: 1280px;' >>$@.tmp
	echo '$$game_h: 720px;' >>$@.tmp
	echo '$$face_w: 280px;' >>$@.tmp
	echo '$$face_h: 280px;' >>$@.tmp
	cat default.scss >>$@.tmp
	mv $@.tmp $@
