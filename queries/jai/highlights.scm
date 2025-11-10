; Includes

[
  (import)
  (load)
] @include


; Keywords
[
  ; from modules/Jai_Lexer
  "if"
  "xx"

  "ifx"
  "for"

  "then"
  "else"
  "null"
  "case"
  "enum"
  "true"
  "cast"

  "while"
  "break"
  "using"
  "defer"
  "false"
  "union"

  "return"
  "struct"
  "inline"
  "remove"

  "size_of"
  "type_of"
  "code_of"
  "context"

  "continue"
  "operator"

  "type_info"
  "no_inline"
  "interface"

  "enum_flags"

  "is_constant"

  "push_context"

  "initializer_of"
  
  ; Additional keywords from emacs mode
  "switch"
  "type_info_none"
  "type_info_procedures_are_void_pointers"
] @keyword

[
  "return"
] @keyword.return

[
  "if"
  "else"
  "case"
  "break"
] @conditional

((if_expression
  [
    "then"
    "ifx"
    "else"
  ] @conditional.ternary)
  (#set! "priority" 105))

; Repeats

[
  "for"
  "while"
  "continue"
] @repeat

; Variables

; (identifier) @variable
name: (identifier) @variable
argument: (identifier) @variable
named_argument: (identifier) @variable
(member_expression (identifier) @variable)
(parenthesized_expression (identifier) @variable)

((identifier) @variable.builtin
  (#any-of? @variable.builtin "context" "it" "it_index"))

; Namespaces

(import (identifier) @namespace)

; Parameters

(parameter (identifier) @parameter ":" "="? (identifier)? @constant)

; (call_expression argument: (identifier) @parameter "=")

; Functions

; (procedure_declaration (identifier) @function (procedure (block)))
; Procedure declarations with various patterns
(procedure_declaration (identifier) @function (block))

; Match procedure patterns like "name :: procedure" or "name: type: procedure"
((identifier) @function
  (#lua-match? @function "^[a-zA-Z_][a-zA-Z0-9_]*$")
  . ":" ":"? . (#any-of? "procedure" "inline" "#type"))

; Function calls
(call_expression function: (identifier) @function.call)

; Types

type: (types) @type
type: (identifier) @type
((types) @type)

modifier: (identifier) @keyword
keyword: (identifier) @keyword

((types (identifier) @type.builtin)
  (#any-of? @type.builtin
    "bool" "int" "string" "void"
    "s8" "s16" "s32" "s64"
    "u8" "u16" "u32" "u64"
    "float" "float32" "float64"
    "Type" "Any"))

(struct_declaration (identifier) @type ":" ":")

(enum_declaration (identifier) @type ":" ":")

; (const_declaration (identifier) @type ":" ":" [(array_type) (pointer_type)])

; ; I don't like this
; ((identifier) @type
;   (#lua-match? @type "^[A-Z][a-zA-Z0-9]*$")
;   (#not-has-parent? @type parameter procedure_declaration call_expression))

; Fields

(member_expression "." (identifier) @field)

(assignment_statement (identifier) @field "="?)
(update_statement (identifier) @field)

; Constants

((identifier) @constant
  (#lua-match? @constant "^_*[A-Z][A-Z0-9_]*$")
  (#not-has-parent? @constant type parameter))

(member_expression . "." (identifier) @constant)

; (enum_field (identifier) @constant)

; Literals

(integer) @number
(float) @number

(string) @string

;(character) @character

(string_contents (escape_sequence) @string.escape)

(boolean) @boolean

[
  (uninitialized)
  (null)
] @constant.builtin

; Operators

[
  ":"
  "="
  "+"
  "-"
  "*"
  "/"
  "%"
  ">"
  ">="
  "<"
  "<="
  "=="
  "!="
  "|"
  "~"
  "&"
  "&~"
  "<<"
  ">>"
  "<<<"
  ">>>"
  "||"
  "&&"
  "!"
  ".."
  "+="
  "-="
  "*="
  "/="
  "%="
  "&="
  "|="
  "^="
  "<<="
  ">>="
  "<<<="
  ">>>="
  "||="
  "&&="
] @operator

; Punctuation

[ "{" "}" ] @punctuation.bracket

[ "(" ")" ] @punctuation.bracket

[ "[" "]" ] @punctuation.bracket

[
  "`"
  "->"
  "."
  ","
  ":"
  ";"
] @punctuation.delimiter

; Comments

[
  (block_comment)
  (comment)
] @comment @spell

; Nested block comments support
(block_comment) @comment

; Errors

(ERROR) @error

(block_comment) @comment

directive: ("#") @keyword ; #if
type: ("type_of") @type

(compiler_directive) @keyword
(heredoc_start) @none
(heredoc_end) @none
(heredoc_body) @string
(note) @string

; Additional highlighting patterns from Emacs mode

; Character literals
((string) @character
  (#lua-match? @character "^'.*'$"))

; Single character literals (like 'a', 'x') 
((identifier) @constant
  (#lua-match? @constant "^'[a-zA-Z0-9_]'$"))

; @ notes  
((identifier) @preproc
  (#lua-match? @preproc "^@[a-zA-Z_][a-zA-Z0-9_]*$"))

; Dollar types like $T
((identifier) @type
  (#lua-match? @type "^\\$[a-zA-Z_][a-zA-Z0-9_]*$"))

; Struct/enum/union literal syntax highlighting
; Foo.{} and bar.[] matching
((identifier) @type
  . "." . ["{" "["])

; Type declaration patterns
((identifier) @type
  . ":" . ":" . ["struct" "enum" "union" "#type"])

; Postfix cast syntax .() 
("." . "(" @operator . ")" @operator)

; Enhanced number literal support (hex, with underscores, etc)
((integer) @number
  (#lua-match? @number "^0x[0-9a-fA-F_]+$"))

((integer) @number
  (#lua-match? @number "^[0-9_]+[a-zA-Z_]*$"))

; Compiler directives from Emacs mode - comprehensive list
; Hash directives
((identifier) @preproc
  (#any-of? @preproc 
    "#add_context" "#align" "#as" "#asm" "#assert" "#bake" "#bake_arguments" 
    "#bytes" "#caller_location" "#c_call" "#char" "#code" "#compiler" 
    "#compile_time" "#complete" "#cpp_method" "#define" "#deprecated" "#dump" 
    "#else" "#endif" "#expand" "#file" "#filepath" "#foreign" "#foreign_library" 
    "#foreign_system_library" "#if" "#ifdef" "#ifndef" "#import" "#insert" 
    "#insert_internal" "#intrinsic" "#library" "#load" "#location" "#modify" 
    "#module_parameters" "#must" "#no_abc" "#no_alias" "#no_aoc" "#no_context" 
    "#no_debug" "#no_padding" "#no_reset" "#place" "#placeholder" "#poke_name" 
    "#procedure_name" "#program_export" "#run" "#run_and_insert" "#runtime_support" 
    "#scope_export" "#scope_file" "#scope_module" "#specified" "#string" 
    "#symmetric" "#system_library" "#this" "#through" "#type" "#type_info_none" 
    "#type_info_procedures_are_void_pointers"))

; Procedure/function name patterns from Emacs mode
; Match: name :: inline? ( or name : type : inline? (
(identifier @function
  . ":" ":"? 
  . (identifier @keyword)? 
  . "(")

; Special constant for triple dash
("---" @constant)

; String with quotes highlighting
((string) @string
  (#lua-match? @string "^\".*\"$"))
