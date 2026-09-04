" Highlight replacement fields in regular strings used with str.format().
syntax match pythonFormatField /{[[:alnum:]_][[:alnum:]_.]*}/ containedin=pythonString
