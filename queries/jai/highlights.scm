; ============================================================================
; INCLUDES & IMPORTS
; ============================================================================

[
  (import)
  (load)
] @keyword.import

; ============================================================================
; KEYWORDS
; ============================================================================

((identifier) @keyword
  (#any-of? @keyword
    "if" "xx" "ifx" "for" "then" "else" "null" "case" "enum" "true" "cast"
    "while" "break" "using" "defer" "false" "union" "return" "struct" "inline"
    "remove" "continue" "operator" "interface" "switch" "size_of" "type_of"
    "code_of" "context" "type_info" "no_inline" "enum_flags" "is_constant"
    "push_context" "initializer_of" "type_info_none"
    "type_info_procedures_are_void_pointers"))

((identifier) @keyword.return
  (#eq? @keyword.return "return"))

((identifier) @keyword.conditional
  (#any-of? @keyword.conditional "if" "else" "case" "break"))

((if_expression
  [
    "then"
    "ifx"
    "else"
  ] @keyword.conditional.ternary)
  (#set! "priority" 105))

; Repeats/loops
((identifier) @keyword.repeat
  (#any-of? @keyword.repeat "for" "while" "continue"))

; ============================================================================
; VARIABLES
; ============================================================================

; (identifier) @variable
name: (identifier) @variable
argument: (identifier) @variable
named_argument: (identifier) @variable
(member_expression (identifier) @variable)
(parenthesized_expression (identifier) @variable)

; Builtin variables (it, it_index, context)
((identifier) @variable.builtin
  (#any-of? @variable.builtin "context" "it" "it_index"))

; ============================================================================
; NAMESPACES
; ============================================================================

(import (identifier) @module)

; ============================================================================
; PARAMETERS
; ============================================================================

(parameter (identifier) @variable.parameter ":" "="? (identifier)? @constant)

; ============================================================================
; FUNCTIONS & PROCEDURES
; ============================================================================

; Procedure declarations with various patterns
(procedure_declaration (identifier) @function.definition (block))

; Function calls
(call_expression function: (identifier) @function.call)

; Procedure/function name patterns from Emacs mode
; Match function declarations like: name :: () {...}
(const_declaration
  name: (identifier) @function.definition
  value: (procedure))

; ============================================================================
; TYPES
; ============================================================================

type: (types) @type
type: (identifier) @type
((types) @type)

modifier: (identifier) @keyword.modifier
keyword: (identifier) @keyword

; Builtin types
((types (identifier) @type.builtin)
  (#any-of? @type.builtin
    "bool" "int" "string" "void"
    "s8" "s16" "s32" "s64"
    "u8" "u16" "u32" "u64"
    "float" "float32" "float64"
    "Type" "Any"))

; Type definitions
(struct_declaration (identifier) @type.definition ":" ":")
(enum_declaration (identifier) @type.definition ":" ":")

; Dollar types like $T, $foo - polymorphic types
((identifier) @type.definition
  (#lua-match? @type.definition "^\\$[a-zA-Z_][a-zA-Z0-9_]*$"))

; Struct/enum/union literal syntax: Foo.{} and bar.[]
((identifier) @type
  . "." . ["{" "["])

; Type declaration patterns: name :: struct/enum/union
((identifier) @type.definition
  . ":" . ":" . ["struct" "enum" "union" "#type"])

; ============================================================================
; FIELDS & PROPERTIES
; ============================================================================

(member_expression "." (identifier) @property)

(assignment_statement (identifier) @property "="?)
(update_statement (identifier) @property)

; ============================================================================
; CONSTANTS
; ============================================================================

; SCREAMING_SNAKE_CASE constants
((identifier) @constant
  (#lua-match? @constant "^_*[A-Z][A-Z0-9_]*$")
  (#not-has-parent? @constant type parameter))

(member_expression . "." (identifier) @constant)

; Single character literals like 'a', 'x'
((identifier) @character
  (#lua-match? @character "^'[a-zA-Z0-9_]'$"))

; ============================================================================
; LITERALS
; ============================================================================

; Numbers
(integer) @number
(float) @number.float

; Enhanced number literals (hex, with underscores)
((integer) @number
  (#lua-match? @number "^0x[0-9a-fA-F_]+$"))

((integer) @number
  (#lua-match? @number "^[0-9_]+[a-zA-Z_]*$"))

; Strings
(string) @string

; Character literals (single quotes)
((string) @character
  (#lua-match? @character "^'.*'$"))

; String with quotes highlighting
((string) @string
  (#lua-match? @string "^\".*\"$"))

(string_contents (escape_sequence) @string.escape)

; Booleans
(boolean) @boolean

; Builtin constants
[
  (uninitialized)
  (null)
] @constant.builtin

; ============================================================================
; OPERATORS
; ============================================================================

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

; Postfix cast syntax .()
("." . "(" @operator . ")" @operator)

; ============================================================================
; PUNCTUATION
; ============================================================================

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

; ============================================================================
; COMMENTS
; ============================================================================

[
  (block_comment)
  (comment)
] @comment @spell

; ============================================================================
; COMPILER DIRECTIVES & MACROS
; ============================================================================

directive: ("#") @keyword.directive
type: ("type_of") @function.builtin

(compiler_directive) @keyword.directive

; Hash directives - use @function.macro for better theme support
((identifier) @function.macro
  (#any-of? @function.macro
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

; @ notes (annotations/attributes) - use @attribute for better theme support
((identifier) @attribute
  (#lua-match? @attribute "^@[a-zA-Z_][a-zA-Z0-9_]*$"))

; Heredoc support
(heredoc_start) @none
(heredoc_end) @none
(heredoc_body) @string
(note) @string

; ============================================================================
; ERRORS
; ============================================================================

(ERROR) @error
