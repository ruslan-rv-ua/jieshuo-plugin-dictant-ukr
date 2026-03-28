-- name: Dictant
-- version: 0.1.0
-- type: JieShuo plugin
-- description: Dictate text to the editor using voice recognition (Ukrainian)
-- author: Ruslan Iskov <ruslan.rv.ua@gmail.com>

-- settings

local CLEAR_EDITOR_PHRASE = "диктант"
local CAPITALIZE_PHRASE = "з великої"
local DELETE_LAST_PHRASE = "видали останнє"
local VIBRATE = true

-- end of settings


-- code

local utf8 = require("utf8")
require "import"
import "android.content.Context"
import "android.content.Intent"
import "android.os.Vibrator"
import "java.util.Locale"
import "android.speech.SpeechRecognizer"
import "android.speech.RecognitionListener"
import "android.speech.RecognizerIntent"


local CAPITALIZE_SYMBOL = "~"

local function decodePunctuations(str)
    -- replace "двокрапка" with ":" and so on
    str = string.gsub(str, "двокрапка", ":") -- ! before `крапка`, because `крапка` is part of the word
    str = string.gsub(str, "три крапки", "...") -- ! before `крапки`, because `крапки` is part of the phrase
    str = string.gsub(str, "крапка", ".")
    str = string.gsub(str, "знак питання", "?")
    str = string.gsub(str, "знак оклику", "!")
    str = string.gsub(str, "кома", ",")
    str = string.gsub(str, "ліва дужка", "(")
    str = string.gsub(str, "права дужка", ")")
    str = string.gsub(str, "тире", "—")
    str = string.gsub(str, "дефіс", "-")
    str = string.gsub(str, "абзац", "\n")
    str = string.gsub(str, CAPITALIZE_PHRASE .. " ", CAPITALIZE_SYMBOL)
    return str
end

local function stripString(str)
    -- strip leading and trailing whitespace
    str = string.gsub(str, "^%s*(.-)%s*$", "%1")
    return str
end

local function stripLines(str)
    -- strip every line of leading and trailing whitespace
    str = string.gsub(str, "\n%s*(.-)%s*\n", "\n%1\n")
    str = string.gsub(str, "^%s*(.-)%s*\n", "%1\n")   -- first line
    str = string.gsub(str, "\n%s*(.-)%s*$", "\n%1")   -- last line
    return str
end

local function formatPunctuations(str)
    -- remove spaces before . , ? ! :
    str = string.gsub(str, "%s+([.,?!:])", "%1")
    return str
end

local function collapseSpaces(str)
    str = string.gsub(str, " +", " ")
    return str
end

local function capitalize(str)
    -- capitalize the first letter of every sentence
    -- also capitalize letters after CAPITALIZE_SYMBOL and delete CAPITALIZE_SYMBOL
    local chars = {}
    for _, codepoint in utf8.codes(str) do
        chars[#chars + 1] = utf8.char(codepoint)
    end
    local capitalizeIndex = 0
    for i, char in ipairs(chars) do
        if capitalizeIndex == 0 and char ~= " " and char ~= "\n" then
            capitalizeIndex = i
        end
        if char == "." or char == "?" or char == "!" then
            if capitalizeIndex > 0 then
                chars[capitalizeIndex] = utf8.upper(chars[capitalizeIndex])
            end
            capitalizeIndex = 0
        elseif char == CAPITALIZE_SYMBOL then
            chars[i] = ""
            if i + 1 <= #chars then
                chars[i + 1] = utf8.upper(chars[i + 1])
            end
        end
    end
    return table.concat(chars)
end


local function startListening()
    -- start voice recognition
    local speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
    local speechListener = RecognitionListener {
        onResults = function(results)
            local data = results.getParcelableArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
            if data ~= nil and data.size() > 0 then
                -- verbalization has been detected
                local recognizedText = data.get(0)
                local prevText = service.getText(node)

                if recognizedText == DELETE_LAST_PHRASE then
                    local stripped = stripString(prevText)
                    local newText = string.match(stripped, "^(.-)%s*%S+%s*$") or ""
                    service.setText(node, newText)
                    if newText == "" then
                        service.appendSpeak("Нічого видаляти")
                    else
                        service.appendSpeak(newText)
                    end
                    return
                elseif string.sub(recognizedText, 1, #CLEAR_EDITOR_PHRASE) == CLEAR_EDITOR_PHRASE then
                    prevText = ""
                    recognizedText = stripString(string.sub(recognizedText, #CLEAR_EDITOR_PHRASE + 1))
                end
                if recognizedText == "" then
                    service.setText(node, prevText)
                    service.appendSpeak(prevText)
                else
                    recognizedText = decodePunctuations(recognizedText)
                    local newText = prevText == "" and recognizedText or prevText .. " " .. recognizedText
                    newText = formatPunctuations(newText)
                    newText = collapseSpaces(newText)
                    newText = stripLines(newText)
                    newText = capitalize(newText)

                    service.setText(node, newText)
                    service.appendSpeak(newText)
                end
            else
                -- If no verbalization was detected on the first attempt, stop voice recognition
                speechRecognizer.destroy()
                return false
            end
        end,
        onError = function()
            -- An error occurred, stop voice recognition
            service.speak("Помилка розпізнавання")
            speechRecognizer.destroy()
            return false
        end
    }

    local recognizerIntent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)
    recognizerIntent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
    recognizerIntent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault())
    recognizerIntent.putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, this.getPackageName())
    speechRecognizer.startListening(recognizerIntent)
    speechRecognizer.setRecognitionListener(speechListener)

    return true
end

local context = activity or service

if VIBRATE then
    local vibrator = context.getSystemService(Context.VIBRATOR_SERVICE)
    if vibrator.hasVibrator() then
        vibrator.vibrate(333)
    end
end

if service.isEditView(node) then
    startListening()
else
    service.speak("Не в редакторі")
end

return true
