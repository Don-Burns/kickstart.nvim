; extends
; Inject SQL when string content begins with a supported SQL statement.

((string (string_content) @injection.content)
  (#match? @injection.content "^\([ \t]*\|\n[ \t]*\|\\[ \t]*\n[ \t]*\|\n[ \t]*--[^\n]*\n[ \t]*\|\\[ \t]*\n[ \t]*--[^\n]*\n[ \t]*\)\?\(SELECT\|UPDATE\|WITH\|INSERT[ \t]\+INTO\|DELETE[ \t]\+FROM\|MERGE[ \t]\+INTO\|CREATE[ \t]\+TABLE\|ALTER[ \t]\+TABLE\|DROP[ \t]\+TABLE\|TRUNCATE\)\>")
  (#set! injection.language "sql"))

((string (string_content (escape_sequence)) @injection.content)
  (#match? @injection.content "SELECT\|UPDATE\|WITH\|INSERT\|DELETE\|MERGE\|CREATE\|ALTER\|DROP\|TRUNCATE")
  (#set! injection.language "sql"))

((string (string_content (escape_sequence)) @injection.content)
  (#match? @injection.content "^[^\n]*--[^\n]*\n[ \t]*\(SELECT\|UPDATE\|WITH\|INSERT\|DELETE\|MERGE\|CREATE\|ALTER\|DROP\|TRUNCATE\)\>")
  (#set! injection.language "sql"))

; F-strings contain interpolation nodes between string_start and string_end.
((string
   (string_start)
   (string_content) @injection.content
   (interpolation))
  (#match? @injection.content "^[ \t]*\(SELECT\|UPDATE\|WITH\|INSERT[ \t]\+INTO\|DELETE[ \t]\+FROM\|MERGE[ \t]\+INTO\|CREATE[ \t]\+TABLE\|ALTER[ \t]\+TABLE\|DROP[ \t]\+TABLE\|TRUNCATE\)\>")
  (#set! injection.language "sql"))
