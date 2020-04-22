script "Hunspell Extension Library"

constant kCategoryLetter = "letter"
constant kCategoryNumber = "number"
constant kCategoryPunctuation = "punctuation"
constant kCategoryWhitespace = "whitespace"
constant kCategoryNonBreaking = "non-breaking"

local tTLDsA

on libraryStack
  if the target is not me then pass libraryStack

  put "com,edu,gov,io,local,mil,net,org,au,ca,cf,cn,de,eu,fr,ga,nl,nl,ru,tk,tv,uk,us" into tTLDsA
  split tTLDsA by "," and "="
end libraryStack


on releaseStack
  if the target is not me then pass releaseStack

  // Cleanup after the extension
  get hunspellDestroy()
end releaseStack


/**
Summary: Classify codepoint as one of letter, number, or punctuation.

Parameters:
pCodepoint: The codepoint to check.

Description:
Based on code provided by the LiveCode team.

Returns: Classification string. See constants.
*/
private function _codepointCategory pCodepoint
  // check if non-breaking space
  if pCodepoint is numToCodepoint(160) then
    return kCategoryNonBreaking
  end if

  local tCategory
  put codepointProperty(pCodepoint, "General_Category") into tCategory
  if tCategory ends with "Letter" then
    return kCategoryLetter
  else if tCategory ends with "Number" then
    return kCategoryNumber
  else
    if codepointProperty(pCodepoint, "White_Space") then
      return kCategoryWhitespace
    end if
    return kCategoryPunctuation
  end if
end _codepointCategory


/**
Summary: Return a sequence of start+end character indices for each word in `pText`.

Parameters:
pText: The string to spell check.

Description:
This function will find an spell check each word in `pText`. If a misspelled word
is found then a COMMA-delimited list of the start+end character numbers is added to
a CR-delimited list of ranges that will be returned.

The scanner will detect urls (strings with :// in them) and not spell check them.
It will also look for a handful of common TLDs (e.g. .com, .edu, etc.) and not spell check
them either.

The returned value can be assigned to the `flaggedRanges` property of a field to
visually mark the misspelled words.

Based on code provided by the LiveCode team.

Returns: CR-delimited list of start+end character indices for misspelled words.
*/
function hunspellFindMisspelledWords pText
  constant kJoinLetter = ".''"
  constant kJoinNumber = ".-,/"

  local tRanges
  local tLength
  local tInsideURL = false
  local tPotentialDomain = false

  put the number of characters in pText into tLength

  local tStartIndex = 1
  repeat while tStartIndex <= tLength
    // skip to word start
    local tCategory

    put _codepointCategory(codepoint 1 of char tStartIndex of pText) into tCategory

    repeat while tStartIndex < tLength
      if tCategory is not kCategoryWhitespace and tCategory is not kCategoryPunctuation then
        exit repeat
      end if
      add 1 to tStartIndex
      put _codepointCategory(codepoint 1 of char tStartIndex of pText) into tCategory
    end repeat

    if tStartIndex > tLength or tCategory is kCategoryWhitespace or tCategory is kCategoryPunctuation then
      exit repeat
    end if

    /*
      Rules for spell checking URLs:
      1. Once user has typed :// then scanner is inside of a url and spell checking
         is turned off until white space is encountered again.
      2. If scanner is not in a url and user types char.char then word will be checked for
         a potential domain.
     */

    local tEndIndex
    put tStartIndex into tEndIndex

    // look for end of word
    repeat while tEndIndex < tLength
      local tNextCharacter
      put character (tEndIndex + 1) of pText into tNextCharacter

      local tNextCategory
      put _codepointCategory(codepoint 1 of tNextCharacter) into tNextCategory
      if tNextCategory is kCategoryLetter or tNextCategory is kCategoryNumber or tNextCategory is kCategoryNonBreaking \
            or (tInsideURL and tNextCategory is not kCategoryWhitespace) then
        add 1 to tEndIndex
        put tNextCategory into tCategory
      else if tInsideURL and tNextCategory is kCategoryWhitespace then
        # End of url
        exit repeat
      else if tEndIndex < tLength - 1 then
        local tThirdCharacter
        put character (tEndIndex + 2) of pText into tThirdCharacter
        put _codepointCategory(codepoint 1 of tThirdCharacter) into tNextCategory
        # Look for special joins characters that continue same word.
        if tNextCategory is tCategory and \
              ((tCategory is kCategoryNumber and tNextCharacter is among the characters of kJoinNumber) or \
              (tCategory is kCategoryLetter and tNextCharacter is among the characters of kJoinLetter)) then
          put tNextCharacter is "." into tPotentialDomain
          add 2 to tEndIndex
        else if tNextCharacter is ":" and tThirdCharacter is "/" and character tEndIndex+3 of pText is "/" then
          # Look for start of url
          put true into tInsideURL
          add 3 to tEndIndex
        else
          exit repeat
        end if
      else
        put false into tInsideURL
        exit repeat
      end if
    end repeat

    local tWord
    local tSpellCheckWord
    put character tStartIndex to tEndIndex of pText into tWord
    put not tInsideURL and (not tPotentialDomain or not _wordHasDomain(tWord)) into tSpellCheckWord

    if tSpellCheckWord then
      if not hunspellSpell(tWord) then
        put tStartIndex & "," & tEndIndex & cr after tRanges
      end if
    end if

    put false into tInsideURL
    put false into tPotentialDomain

    put tEndIndex + 1 into tStartIndex
  end repeat

  delete the last char of tRanges

  return tRanges
end hunspellFindMisspelledWords


/**
Summary: Detects some common TLDs to determine if a word should be spell checked.

Parameters:
pWord: The word to check.

Description:
If a word ends in a TLD then it should not be spell checked.
The current implementation does not contain an exhaustive list by any means.

Returns: Boolean
*/
private function _wordHasDomain pWord
  set the itemDelimiter to "."
  return item -1 of pWord is among the keys of tTLDsA
end _wordHasDomain
