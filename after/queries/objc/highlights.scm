; extends

; Treat arc_*/ark_*/yg_* macros as macros (sky-blue, like 4coder index_macro)
((identifier) @function.macro
  (#any-of? @function.macro
    "internal" "inline" "global" "local_persist" "function" "static"
    "arc_internal" "arc_inline" "arc_global" "arc_local_persist"
    "ark_internal" "ark_inline" "ark_global" "ark_local_persist"
    "yg_internal" "yg_inline" "yg_global" "yg_local_persist")
  (#set! priority 200))

((type_identifier) @function.macro
  (#any-of? @function.macro
    "internal" "inline" "global" "local_persist" "function" "static"
    "arc_internal" "arc_inline" "arc_global" "arc_local_persist"
    "ark_internal" "ark_inline" "ark_global" "ark_local_persist"
    "yg_internal" "yg_inline" "yg_global" "yg_local_persist")
  (#set! priority 200))

; Fix function declarations/definitions that start with custom macros
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
; e.g., "function id<MTLTexture>\n         metal_create_depth_texture(...)"
; The parser keeps this as one function_definition with id/MTLTexture in an ERROR node
(function_definition
  (ERROR
    (identifier) @type))

(declaration
  (ERROR
    (identifier) @type))

; Fix "function ReturnType" parsed as a declaration (return type on its own line)
; e.g., "function MTLStorageMode" → declaration with MTLStorageMode as identifier
; The actual return type should be highlighted as @type, not @variable
(declaration
  type: (type_identifier) @_macro
  declarator: (identifier) @type
  (#any-of? @_macro
    "internal" "inline" "global" "local_persist" "function" "static"
    "arc_internal" "arc_inline" "arc_global" "arc_local_persist"
    "ark_internal" "ark_inline" "ark_global" "ark_local_persist"
    "yg_internal" "yg_inline" "yg_global" "yg_local_persist")
  (#set! priority 200))

; Fix function name misidentified as type when return type is on previous line
; e.g., "metal_static_storage_mode(void)" parsed as function_definition where the
; function name becomes type_identifier and (void) becomes parenthesized_declarator
(function_definition
  type: (type_identifier) @function
  declarator: (parenthesized_declarator)
  (#set! priority 200))

; Fix void being parsed as variable - force it to be a type
((identifier) @type.builtin
  (#any-of? @type.builtin "void"))

; Base type aliases as identifier
((identifier) @type
  (#any-of? @type
    "b8" "b16" "b32" "b64"
    "s8" "s16" "s32" "s64"
    "u8" "u16" "u32" "u64"
    "f32" "f64"
    "f32x4" "i32x4" "u32x4" "u8x16" "b32x4" "b8x16"
    "UAddr" "uaddr" "saddr")
  (#set! priority 200))

; Base type aliases as type_identifier (struct fields, declarations)
((type_identifier) @type
  (#any-of? @type
    "b8" "b16" "b32" "b64"
    "s8" "s16" "s32" "s64"
    "u8" "u16" "u32" "u64"
    "f32" "f64"
    "f32x4" "i32x4" "u32x4" "u8x16" "b32x4" "b8x16"
    "UAddr" "uaddr" "saddr")
  (#set! priority 200))
