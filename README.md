# lc-hunspell
LCB Wrapper around Hunspell

This repo contains version 1.6.2 of Hunspell for 32-bit and 64-bit Windows. The hunspell.lcb file wraps these DLLs and provides an API for doing the following:

- Spell checking a word
- Getting suggested words for a misspelled word
- Adding a word to the in-memory dictionary
- Removing a word from the in-memory dictionary

The hunspell.livecodescript file is intended to be used as a library. It provides the `hunspellFindMisspelledWords` function which will spell check a run of text and returns character ranges for all misspelled words. The return value can be assigned to the `flaggedRanges` property of a field.

## Dictionaries

A French dictionary is included for testing purposes. Dictionaries in a variety of languages that are in the correct format for use with hunspell can be found in the following github repo:

https://github.com/wooorm/dictionaries

# Linux and macoS Support

## Linux

Support can be added to this repo by compiling the hunspell library as a shared object library (.so) for both 32 and 64-bit. The 32-bit library should be added as `./code/x86-linux/libhunspell.so` and the 64-bit version should be added as `./code/x86_64-linux/libhunspell.so`.

## macOS

macOS provides a built-in spell checker which should be used. A wrapper around NSSpellChecker for macOS can be found at the following url:

https://github.com/trevordevore/lc-macos-toolset/blob/master/NSSpellChecker/nsspellchecker.lcb

If you want to work on the extension on macOS then add a hunspell dylib to `./code/x86_64-mac/libhunspell.dylib`.

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
