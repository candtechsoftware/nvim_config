; extends

; Treat yg_* macros as storage class modifiers (teal color)
((identifier) @keyword.modifier
  (#any-of? @keyword.modifier "yg_internal" "yg_inline" "yg_global" "yg_local_persist"))

; Fix function declarations that start with yg_* macros
; Pattern: yg_internal TYPE funcname(...) or yg_internal TYPE *funcname(...)
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
