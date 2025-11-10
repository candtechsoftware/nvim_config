; Scopes
[
  (block)
  (procedure_declaration)
  (struct_declaration)
  (enum_declaration)
  (for_statement)
  (while_statement)
  (if_statement)
] @scope

; Definitions
(procedure_declaration
  name: (identifier) @definition.function)

(struct_declaration
  name: (identifier) @definition.type)

(enum_declaration
  name: (identifier) @definition.type)

(parameter
  name: (identifier) @definition.parameter)

; Variable definitions
(assignment_statement
  (identifier) @definition.variable)

; References
(identifier) @reference

; Function calls
(call_expression
  function: (identifier) @reference.call)

; Member access
(member_expression
  field: (identifier) @reference.field)