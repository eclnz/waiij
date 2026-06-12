export TokenType, Token
export ILLEGAL, EOF, IDENT, INT
export ASSIGN, PLUS, MINUS, BANG, ASTERIK, SLASH
export LT, GT, EQ, NOT_EQ
export COMMA, SEMICOLON, LPAREN, RPAREN, LBRACE, RBRACE
export FUNCTION, LET, IF, ELSE, RETURN, TRUE, FALSE
export KW_TOKENS, CHAR_TOKENS
export LOWEST, EQUALS, LESSGREATER, SUM, PRODUCT, PREFIX, CALL

const TokenType = String

struct Token
    type::TokenType
    literal::String
end

const ILLEGAL   = "ILLEGAL"
const EOF       = "EOF" # since this is not '/0' it needs to be a special case.

const IDENT     = "IDENT"
const INT       = "INT"

const ASSIGN    = "="
const PLUS      = "+"
const MINUS     = "-"
const BANG      = "!"
const ASTERIK   = "*"
const SLASH     = "/"

const LT        = "<"
const GT        = ">"

const EQ        = "=="
const NOT_EQ    = "!="

const COMMA     = ","
const SEMICOLON = ";"
const LPAREN    = "("
const RPAREN    = ")"
const LBRACE    = "{"
const RBRACE    = "}"

const FUNCTION  = "FUNCTION"
const LET       = "LET"
const IF        = "IF"
const ELSE      = "ELSE"
const RETURN    = "RETURN"
const TRUE      = "TRUE"
const FALSE     = "FALSE"



const KW_TOKENS = Dict(
    "fn" => FUNCTION,
    "let" => LET,
    "if" => IF,
    "return" => RETURN,
    "true" => TRUE,
    "false" => FALSE,
    "else" => ELSE
)

const CHAR_TOKENS = Dict(
    '=' => ASSIGN,
    ';' => SEMICOLON,
    '(' => LPAREN,
    ')' => RPAREN,
    '+' => PLUS,
    '{' => LBRACE,
    '}' => RBRACE,
    '-' => MINUS,
    '>' => GT,
    '<' => LT,
    '!' => BANG,
    '*' => ASTERIK,
    '/' => SLASH,
    ',' => COMMA,
)

# Precedence
const LOWEST = 1
const EQUALS = 2
const LESSGREATER = 3
const SUM = 4
const PRODUCT = 5
const PREFIX = 6
const CALL = 7