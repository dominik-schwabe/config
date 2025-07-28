(symbol) @string.special.symbol
(prefix (name) @function)
(infix (name) @operator)
(escape_sequence) @string.escape
(string) @string
(bytes) @string.regexp
(byte_escape_sequence) @string.escape

["(" ")" "[" "]" "{" "}"] @punctuation.bracket
