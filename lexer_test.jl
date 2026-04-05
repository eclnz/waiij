
include("lexer.jl")

function check_tokens(input::String, expected_tokens::Vector{Token})
    l = new(input)
    for (i, tt) in enumerate(expected_tokens)
        tok = next_token(l)
        println("Token $i:")
        println("  Expected: type = $(tt.type), literal = \"$(tt.literal)\"")
        println("  Actual:   type = $(tok.type), literal = \"$(tok.literal)\"")
        println()
    end
end

input = """let five = 5;
let ten = 10;
let add = fn(x, y) {
    x + y;
};
let result = add(five, ten);"""
expected_tokens = [
    Token(LET, "let"),
    Token(IDENT, "five"),
    Token(ASSIGN, "="),
    Token(INT, "5"),
    Token(SEMICOLON, ";"),
    Token(LET, "let"),
    Token(IDENT, "ten"),
    Token(ASSIGN, "="),
    Token(INT, "10"),
    Token(SEMICOLON, ";"),
    Token(LET, "let"),
    Token(IDENT, "add"),
    Token(ASSIGN, "="),
    Token(FUNCTION, "fn"),
    Token(LPAREN, "("),
    Token(IDENT, "x"),
    Token(COMMA, ","),
    Token(IDENT, "y"),
    Token(RPAREN, ")"),
    Token(LBRACE, "{"),
    Token(IDENT, "x"),
    Token(PLUS, "+"),
    Token(IDENT, "y"),
    Token(SEMICOLON, ";"),
    Token(RBRACE, "}"),
    Token(SEMICOLON, ";"),
    Token(LET, "let"),
    Token(IDENT, "result"),
    Token(ASSIGN, "="),
    Token(IDENT, "add"),
    Token(LPAREN, "("),
    Token(IDENT, "five"),
    Token(COMMA, ","),
    Token(IDENT, "ten"),
    Token(RPAREN, ")"),
    Token(SEMICOLON, ";"),
    Token(EOF, "")
]
check_tokens(input, expected_tokens)
