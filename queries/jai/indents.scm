; Indentation for Jai. Consumed by lua/config/ts_indent.lua (the native port of
; nvim-treesitter's indent engine -- core Neovim has no indent engine of its
; own, so nothing else reads this file).
;
; Capture meanings, as implemented by that engine:
;   @indent.begin   children get one shiftwidth; ignored on the node's own
;                   start line, and for nodes that open and close on one line
;   @indent.branch  dedent when this node *starts* the line (closing brackets)
;   @indent.dedent  dedent when this node does not start the line
;   @indent.align   line up continuations under a delimiter -- open/close are
;                   named with (#set! indent.open_delimiter "(") etc.
;   @indent.end     marks a closer, so `o` on a blank line picks the right node
;   @indent.auto    leave the line's indent alone
;
; The predecessor of this file shipped with tree-sitter-jai and was explicitly
; marked "Incomplete" by its author; it had no alignment rules at all, which is
; the part that matters most for Jai's wrapped parameter lists.


; ---------------------------------------------------------------------------
; Aligned bracket groups.
;
; A wrapped argument or parameter list lines up under the column just past its
; opening bracket:
;
;     emit_sprite_quad :: (x0: float, y0: float, x1: float,
;                          y1: float, u0: float, v_bottom: float,
;                          v_top: float, flip_x := false) {
;
; When the bracket instead ends its line, the engine falls back to a hanging
; indent of one shiftwidth, which is the other style Jai code uses:
;
;     thing := Foo.{
;         a = 1,
;     };
; ---------------------------------------------------------------------------

; Procedure declarations and procedure types.
((named_parameters) @indent.align
  (#set! indent.open_delimiter "(")
  (#set! indent.close_delimiter ")"))

; Call arguments, and `#import "X"(...)` module parameters.
((assignment_parameters) @indent.align
  (#set! indent.open_delimiter "(")
  (#set! indent.close_delimiter ")"))

; `#insert` parameters.
((insert_parameters) @indent.align
  (#set! indent.open_delimiter "(")
  (#set! indent.close_delimiter ")"))

; `-> (a: int, b: int)`. Bare returns (`-> int`) have no `(` child, and the
; engine skips the rule when the named delimiter is absent.
((procedure_returns) @indent.align
  (#set! indent.open_delimiter "(")
  (#set! indent.close_delimiter ")"))

((parenthesized_expression) @indent.align
  (#set! indent.open_delimiter "(")
  (#set! indent.close_delimiter ")"))

((struct_literal) @indent.align
  (#set! indent.open_delimiter "{")
  (#set! indent.close_delimiter "}"))

((array_literal) @indent.align
  (#set! indent.open_delimiter "[")
  (#set! indent.close_delimiter "]"))

((index_expression) @indent.align
  (#set! indent.open_delimiter "[")
  (#set! indent.close_delimiter "]"))

; A binary expression continued on the next line aligns under its own first
; operand, so the operator leads the continuation:
;
;     wobble := 1.0
;               + 0.22 * sin(angle * 3.0 + 0.7)
;
; increment 0 means "align with the start", not "one past it". Nested inside a
; call this still resolves to the argument column, because the expression
; itself starts there.
((binary_expression) @indent.align
  (#set! indent.increment 0))

; The same treatment for a wrapped `ifx`, whose `then`/`else` line up under it:
;
;     scroll_content_size := ifx is_vertical
;                            then max(inner.y + inner.h - min_y, inner.h)
;                            else max(max_x - inner.x, inner.w);
((if_expression) @indent.align
  (#set! indent.increment 0))


; ---------------------------------------------------------------------------
; Braced bodies. Each of these spans from its own first line down to `}`, so
; one shiftwidth applies to everything in between.
; ---------------------------------------------------------------------------

[
  (block)                  ; procedure bodies, `if`/`for`/`while`/`defer` blocks
  (struct_or_union_block)  ; struct and union bodies
  (enum_declaration)       ; `Tile :: enum u8 { ... }`
  (anonymous_enum_type)    ; `facing: enum { FRONT; BACK; }` -- a field's type
  (anonymous_struct_type)  ; likewise for an inline struct type
  (asm_statement)          ; `#asm { ... }`
  (if_case_statement)      ; `if value == { ... }`
  (switch_case)            ; a `case ...;` and the statements under it
] @indent.begin


; ---------------------------------------------------------------------------
; Unbraced single-statement bodies, where the statement wrapped onto its own
; line:
;
;     if !sheet
;         return;
;
; A braced body is excluded structurally rather than by text matching: `;` is a
; direct child of the consequence only when there is no block.
;
; The parent node is what carries @indent.begin, because it is the one that
; starts back on the `if` line -- a node adds nothing to the line it begins on,
; so capturing the consequence itself would do nothing.
;
; That parent's indent would also leak into an `else` branch, so the two shapes
; are matched separately: no else at all, and else with an unbraced consequence
; of its own (below). A *braced* else after an unbraced `if` matches neither,
; and those lines keep block indent rather than cascading wrongly -- the block
; rule above already gets the braced-else body right.
; ---------------------------------------------------------------------------

(if_statement_condition_and_consequence
  consequence: (statement ";" @indent.end)
  !alternative) @indent.begin

; Fully unbraced if/else:
;
;     if x.high
;         return tprint("0x%0_%0", ...);
;     else
;         return tprint("%0", x.low);
;
; @indent.branch pulls the `else` line itself back level with the `if`, and
; @indent.dedent cancels the parent's step for the lines under it -- which the
; else_clause rule below then re-adds, so the two branches land level.
(if_statement_condition_and_consequence
  consequence: (statement ";")
  alternative: (else_clause
    consequence: (statement ";")) @indent.branch @indent.dedent) @indent.begin

(else_clause
  consequence: (statement ";" @indent.end)) @indent.begin

(for_statement
  body: (statement ";" @indent.end)) @indent.begin

(while_statement
  body: (statement ";" @indent.end)) @indent.begin

(defer_statement
  (statement ";" @indent.end)) @indent.begin

(using_statement
  (statement ";" @indent.end)) @indent.begin


; ---------------------------------------------------------------------------
; Closing delimiters pull their own line back out one level.
; ---------------------------------------------------------------------------

[
  ")"
  "]"
  "}"
] @indent.branch @indent.end


; ---------------------------------------------------------------------------
; Regions whose contents are not ours to move.
; ---------------------------------------------------------------------------

[
  (comment)         ; only fires for lines *inside* a multi-line comment
  (block_comment)
  (string_directive) ; #string HERE ... HERE -- the body is literal text
  (string)
  (ERROR)           ; half-typed code: keep what the author has
] @indent.auto
