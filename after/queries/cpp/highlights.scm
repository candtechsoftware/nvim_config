; extends

; The C-family fixes (storage-class macros, base type aliases, enum member
; names) live in after/queries/c. cpp inherits c, so they already apply here;
; repeating them made every cpp buffer compile and match them twice.

; Enum member references in case values: `case EnumType::Value:`
; Force the name after `::` to be a constant so mixed-case enum members
; (Blur, Shadow, Geo3D) match all-caps ones (UI, ID) instead of being
; misclassified as types by name-pattern heuristics.
(case_statement
  value: (qualified_identifier
    name: (identifier) @constant)
  (#set! priority 200))

(case_statement
  value: (qualified_identifier
    name: (qualified_identifier
      name: (identifier) @constant))
  (#set! priority 200))

; Enum member references through `Type::Value` in common value contexts
; (deliberately excludes call_expression's function field so static method
; calls keep their @function.call coloring)
(assignment_expression
  right: (qualified_identifier
    name: (identifier) @constant)
  (#set! priority 200))

(return_statement
  (qualified_identifier
    name: (identifier) @constant)
  (#set! priority 200))

(argument_list
  (qualified_identifier
    name: (identifier) @constant)
  (#set! priority 200))

(binary_expression
  (qualified_identifier
    name: (identifier) @constant)
  (#set! priority 200))

(initializer_list
  (qualified_identifier
    name: (identifier) @constant)
  (#set! priority 200))

(init_declarator
  value: (qualified_identifier
    name: (identifier) @constant)
  (#set! priority 200))

(conditional_expression
  (qualified_identifier
    name: (identifier) @constant)
  (#set! priority 200))

(field_initializer
  (qualified_identifier
    name: (identifier) @constant)
  (#set! priority 200))
