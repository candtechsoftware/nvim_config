; Foldable structures
[
  (block)
  (struct_declaration)
  (enum_declaration)
  (procedure_declaration)
  (if_statement)
  (for_statement)
  (while_statement)
  (switch_statement)
  (block_comment)
] @fold

; Fold multiline comments
((comment) @fold
 (#lua-match? @fold "\n"))

; Fold heredoc strings
(heredoc_body) @fold