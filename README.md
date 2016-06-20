# Mikan Visual Novel Engine

Mikan is a simple engine to read visual novels in `.story` format.
`.story` format is a simple [JSON]-based format designed with an idea to
make a high-level engine-neutral storage format for visual novels.

As of now, there are no novels natively published in `.story` format, but
there are several converters available to convert existing commerical
visual novels running popular engines into `.story` format. Using such
converters one can potentially run *any* visual novel using Mikan
engine.

Pros of using Mikan engine to read visual novels:

* **Portability**. It is written in HTML5+JS and thus can run virtually anywhere. You can
read novels on Android tablets / phones, iPads, iPhones, Linux desktops,
Mac OS X desktops, smart TVs, etc.

* **Web access**. One can publish a novel online (using regular web
server) and there would be no need to download anything for a reader to
read it - one would just open a link and start reading.

* **Better UI**. If you don't like an UI (looks or interactions) designed
by novel authors, you can use a custom UI - or basically any other UI
from any other ported novel.

* **Language learner**. If you want to learn languages reading visual
novels, there are plethora of options to do that using Mikan:

  * Switch language on the fly
  * Bilingual support - show phrase in two languages (like, Japanese and
  English) simultaneously and learn
  * Annotated Japanese - get Japanese phrases with part-of-speech
  annotations, sentence construction hints, [furigana] and dictionary
  lookups using [MeCab] or [JMDict]

* **Automatic translation**. If you want to read untranslated novels, you
can plug in any automated translator.

* **Cloud-based saves**. You can use either saving states of your games
in local storage (using it only in one device/browser), or you can opt
for saving/loading games in/from the cloud. The latter allows you to
start reading a VN at home PC, continue reading it (loading reading
state) on the go using your Android tablet while commuting to your
work/school and continue to read it at your work PC there ;)

* Proprietary platforms (and engines targeting them) that run visual
novels come and go, open standards (like `.story`, HTML or JavaScript)
are here to stay. Take a look at history: there are thousands of novels
published for PC98 platform, yet you can't even buy the hardware
nowadays. Mikan engine and `.story` format are meant to preserve creative
objects (i.e. visual novels) for ages to come.

* **Free/open source**. Engine is free and open source, licensed under
AGPL.

Of course, there are also several cons of using Mikan engine:

* Obviously, one can run only novels converted to (or written in)
`.story` format. If the engine is unsupported, you can either dive in and
implement converter for it (that would require some reverse engineering
skills) or wait/request for someone else to do it.

* In some cases, there would be differences between original engine and
Mikan port. Mature, polished conversions keep this differences to minimum
(or zero), but using early versions of converters will likely to result
in missed animations, misaligned sprites, messed up layers, etc. Your
mileage may vary.

[JSON]: http://json.org/
[furigana]: https://en.wikipedia.org/wiki/Furigana
[MeCab]: https://sourceforge.net/projects/mecab/
[JMDict]: https://en.wikipedia.org/wiki/EDICT

## Supported engines and available converters

TODO

## Compatibility list (novels known to run)

TODO

## Quick start

TODO

## Similar projects

There are a few projects that share similar ideas. What's different about
Mikan and `.story`?

* [ViLE] is a universal virtual machine for visual novels. Compared to
Mikan, which uses complex converters + very simple `.story` format + very
simple unified engine, ViLE uses original data files + complex virtual
machine to process them. Unfortunately, project seems to be dead since
~2011.

* [VNDS] uses the same principle (i.e. converters + simple engine), but
`.novel` format used in VNDS is much lower level than `.story` format.
Roughly comparing, `.story` uses concepts like "dialogue line", which
involves a defined "character", text (probably in multiple languages),
voice for that line, character facial expression associated with line,
etc, while `.novel` uses much lower level stuff like "output text in the
window", "put graphics N at place M", etc. And, again, unfortunately,
VNDS seems to be abandoned since ~2013.

[ViLE]: http://vilevn.org/
[VNDS]: http://weeaboo.nl/category/vnds/
[NScripter]: http://nscripter.insani.org/
