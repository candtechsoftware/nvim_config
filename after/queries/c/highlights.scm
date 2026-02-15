; extends

; Treat ark_* macros as storage class modifiers
((identifier) @keyword.modifier
  (#any-of? @keyword.modifier "ark_internal" "ark_inline" "ark_global" "ark_local_persist"))

; Fix function declarations that start with ark_* macros
; Pattern: ark_internal TYPE funcname(...) or ark_internal TYPE *funcname(...)
(declaration
  declarator: (function_declarator
    declarator: (identifier) @function))

(declaration
  declarator: (pointer_declarator
    declarator: (function_declarator
      declarator: (identifier) @function)))

; Fix void being parsed as variable - force it to be a type
((identifier) @type.builtin
  (#any-of? @type.builtin "void"))

; Base type aliases - always highlight as types regardless of context
((identifier) @type.builtin
  (#any-of? @type.builtin
    "b8" "b16" "b32" "b64"
    "s8" "s16" "s32" "s64"
    "u8" "u16" "u32" "u64"
    "f32" "f64"))
