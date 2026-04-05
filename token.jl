const TokenType = String

struct Token
    type::TokenType
    literal::String
end

const ILLEGAL    = "ILLEGAL"
const EOF        = "EOF"

const IDENT      = "IDENT"    # add, foobar, x, y, ...
const INT        = "INT"      # 1343456

const ASSIGN     = "="
const PLUS       = "+"

const COMMA      = ","
const SEMICOLON  = ";"
const LPAREN     = "("
const RPAREN     = ")"
const LBRACE     = "{"
const RBRACE     = "}"

const FUNCTION   = "FUNCTION"
const LET        = "LET"
const IF         = "IF"
const RETURN     = "RETURN"