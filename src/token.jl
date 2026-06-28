export TokenType, Token, token_literal
export ILLEGAL, EOF, IDENT, INT
export ASSIGN, PLUS, MINUS, BANG, ASTERIK, SLASH
export LT, GT, EQ, NOT_EQ
export COMMA, SEMICOLON, LPAREN, RPAREN, LBRACE, RBRACE
export FUNCTION, LET, IF, ELSE, RETURN, TRUE, FALSE
export KW_TOKENS, CHAR_TOKENS
export LOWEST, EQUALS, LESSGREATER, SUM, PRODUCT, PREFIX, CALL
export EOF_CHAR, WHITESPACE_CHARS, ASSIGN_CHAR

@enum TokenType begin
    ILLEGAL; EOF
    IDENT; INT
    ASSIGN; PLUS; MINUS; BANG; ASTERIK; SLASH
    LT; GT; EQ; NOT_EQ
    COMMA; SEMICOLON
    LPAREN; RPAREN; LBRACE; RBRACE
    FUNCTION; LET; IF; ELSE; RETURN
    TRUE; FALSE
end

const EOF_CHAR = '\0'
const WHITESPACE_CHARS = (' ', '\t', '\n', '\r')
const ASSIGN_CHAR = '='

struct Token
    type::TokenType
    literal::String
end

Token(token::TokenType) = Token(token, token_literal(token))

const TOKEN_LITERALS = Dict{TokenType, String}(
    ILLEGAL   => "ILLEGAL",
    EOF       => "EOF",    
    IDENT     => "IDENT",
    INT       => "INT",
    ASSIGN    => "=",
    PLUS      => "+",
    MINUS     => "-",
    BANG      => "!",
    ASTERIK   => "*",
    SLASH     => "/",
    LT        => "<",
    GT        => ">",
    EQ        => "==",
    NOT_EQ    => "!=",
    COMMA     => ",",
    SEMICOLON => ";",
    LPAREN    => "(",
    RPAREN    => ")",
    LBRACE    => "{",
    RBRACE    => "}",
    FUNCTION  => "FUNCTION",
    LET       => "LET",
    IF        => "IF",
    ELSE      => "ELSE",
    RETURN    => "RETURN",
    TRUE      => "TRUE",
    FALSE     => "FALSE",
)

token_literal(t::TokenType) = TOKEN_LITERALS[t]

const KW_TOKENS = Dict{String, TokenType}(
    "fn"     => FUNCTION,
    "let"    => LET,
    "if"     => IF,
    "return" => RETURN,
    "true"   => TRUE,
    "false"  => FALSE,
    "else"   => ELSE,
)

const CHAR_TOKENS = Dict{Char, TokenType}(
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