script "Hunspell Extension Library"

constant kCategoryLetter = "letter"
constant kCategoryNumber = "number"
constant kCategoryPunctuation = "punctuation"
constant kCategoryWhitespace = "whitespace"
constant kCategoryNonBreaking = "non-breaking"


on libraryStack
  if the target is not me then pass libraryStack

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

    local tEndIndex
    put tStartIndex into tEndIndex

    // look for end of word
    repeat while tEndIndex < tLength
      local tNextCharacter
      put character (tEndIndex + 1) of pText into tNextCharacter

      local tNextCategory
      put _codepointCategory(codepoint 1 of tNextCharacter) into tNextCategory
      if tNextCategory is kCategoryLetter or tNextCategory is kCategoryNumber or tNextCategory is kCategoryNonBreaking then
        add 1 to tEndIndex
        put tNextCategory into tCategory
      else if tEndIndex < tLength - 1 then
        put _codepointCategory(codepoint 1 of character (tEndIndex + 2) of pText) into tNextCategory
        if tNextCategory is tCategory and \
              ((tCategory is kCategoryNumber and tNextCharacter is among the characters of kJoinNumber) or \
              (tCategory is kCategoryLetter and tNextCharacter is among the characters of kJoinLetter)) then
          add 2 to tEndIndex
        else
          exit repeat
        end if
      else
        exit repeat
      end if
    end repeat

    if not hunspellSpell(character tStartIndex to tEndIndex of pText) then
      put tStartIndex & "," & tEndIndex & cr after tRanges
    end if

    put tEndIndex + 1 into tStartIndex
  end repeat

  delete the last char of tRanges

  return tRanges
end hunspellFindMisspelledWords