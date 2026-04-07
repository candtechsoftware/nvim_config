; extends

; Treat arc_*/ark_*/yg_* macros as macros (sky-blue, like 4coder index_macro)
((identifier) @function.macro
  (#any-of? @function.macro
    "internal" "inline" "global" "local_persist"
    "arc_internal" "arc_inline" "arc_global" "arc_local_persist"
    "ark_internal" "ark_inline" "ark_global" "ark_local_persist"
    "yg_internal" "yg_inline" "yg_global" "yg_local_persist")
  (#set! priority 200))

((type_identifier) @function.macro
  (#any-of? @function.macro
    "internal" "inline" "global" "local_persist"
    "arc_internal" "arc_inline" "arc_global" "arc_local_persist"
    "ark_internal" "ark_inline" "ark_global" "ark_local_persist"
    "yg_internal" "yg_inline" "yg_global" "yg_local_persist")
  (#set! priority 200))

; Fix function declarations/definitions that start with custom macros
; The macro causes an ERROR node but function_declarator structure is still correct
(declaration
  declarator: (function_declarator
    declarator: (identifier) @function))

(declaration
  declarator: (pointer_declarator
    declarator: (function_declarator
      declarator: (identifier) @function)))

(function_definition
  declarator: (function_declarator
    declarator: (identifier) @function))

(function_definition
  declarator: (pointer_declarator
    declarator: (function_declarator
      declarator: (identifier) @function)))

; Fix return types swallowed by ERROR nodes after custom storage-class macros
; e.g., "internal u8x16 func()" → treesitter parses "internal" as type, real
; return type lands in ERROR node as a plain identifier
(function_definition
  (ERROR
    (identifier) @type))

(declaration
  (ERROR
    (identifier) @type))

; Fix void being parsed as variable - force it to be a type
((identifier) @type.builtin
  (#any-of? @type.builtin "void"))

; Base type aliases as identifier
((identifier) @type
  (#any-of? @type
    "b8" "b16" "b32" "b64"
    "s8" "s16" "s32" "s64"
    "u8" "u16" "u32" "u64"
    "f32" "f64")
  (#set! priority 200))

; Base type aliases as type_identifier (struct fields, declarations)
((type_identifier) @type
  (#any-of? @type
    "b8" "b16" "b32" "b64"
    "s8" "s16" "s32" "s64"
    "u8" "u16" "u32" "u64"
    "f32" "f64")
  (#set! priority 200))
