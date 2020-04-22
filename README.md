# lc-hunspell
LCB Wrapper around Hunspell

This repo contains version 1.6.2 of Hunspell for 32-bit and 64-bit Windows. A wrapper around NSSpellChecker for macOS can be found at the following url:

https://github.com/trevordevore/lc-macos-toolset/blob/master/NSSpellChecker/nsspellchecker.lcb

## Testing

1. Download a Zip of this repo using the **Clone or download** button.
2. In the LiveCode IDE use the Tools > Extension Builder menu to open the Extension Builder.
3. Click on the folder icon in the top right of the window and open the **hunspell.lcb** file.
4. Click the Play button in the bottom left of the window to compile and load the hunspell extension.
5. Use File > Open Stack... menu itme to open the hunspell-test-suite.livecode file.
6. Click the **Initialize** button.
7. Click **Get Encoding**. You should see *UTF-8* appear in the field to the right.
8. Click **Check Word**. *false* should appear in the *Spelled correctly?* field.
9. Click **Suggestions** and a list of suggestions should appear to the right.
10. Click **Check String&** and the misspelled words should be flagged in the field below. (Still a work in progress.)
