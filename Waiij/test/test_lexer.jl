using Waiij

T(type::String) = Token(type, type)

function check_tokens(input::String, expected_tokens::Vector{Token})
    l = Lexer(input)
    for (i, tt) in enumerate(expected_tokens)
        tok = next_token!(l)
        @assert tt.type == tok.type "[$i] type: expected=$(tt.type) got=$(tok.type) literal=$(tok.literal)"
        @assert tt.literal == tok.literal "[$i] literal: expected=$(tt.literal) got=$(tok.literal)"
    end
end

check_tokens("let five = 5;", [Token(LET, "let"), Token(IDENT, "five"), T(ASSIGN), Token(INT, "5"), T(SEMICOLON), T(EOF)])
check_tokens("let ten = 10;", [Token(LET, "let"), Token(IDENT, "ten"), T(ASSIGN), Token(INT, "10"), T(SEMICOLON), T(EOF)])
check_tokens("let add = fn(x, y) {\n    x + y;\n};", [
    Token(LET, "let"), Token(IDENT, "add"), T(ASSIGN),
    Token(FUNCTION, "fn"), T(LPAREN), Token(IDENT, "x"), T(COMMA), Token(IDENT, "y"), T(RPAREN), T(LBRACE),
    Token(IDENT, "x"), T(PLUS), Token(IDENT, "y"), T(SEMICOLON),
    T(RBRACE), T(SEMICOLON), T(EOF),
])
check_tokens("let result = add(five, ten);", [
    Token(LET, "let"), Token(IDENT, "result"), T(ASSIGN),
    Token(IDENT, "add"), T(LPAREN), Token(IDENT, "five"), T(COMMA), Token(IDENT, "ten"), T(RPAREN),
    T(SEMICOLON), T(EOF),
])
check_tokens("!-/*5;", [T(BANG), T(MINUS), T(SLASH), T(ASTERIK), Token(INT, "5"), T(SEMICOLON), T(EOF)])
check_tokens("5 < 10 > 5;", [Token(INT, "5"), T(LT), Token(INT, "10"), T(GT), Token(INT, "5"), T(SEMICOLON), T(EOF)])
check_tokens("if (5 < 10) {\n    return true;\n} else {\n    return false;\n}", [
    Token(IF, "if"), T(LPAREN), Token(INT, "5"), T(LT), Token(INT, "10"), T(RPAREN), T(LBRACE),
    Token(RETURN, "return"), Token(TRUE, "true"), T(SEMICOLON),
    T(RBRACE), Token(ELSE, "else"), T(LBRACE),
    Token(RETURN, "return"), Token(FALSE, "false"), T(SEMICOLON),
    T(RBRACE), T(EOF),
])
check_tokens("10 == 10;", [Token(INT, "10"), T(EQ), Token(INT, "10"), T(SEMICOLON), T(EOF)])
check_tokens("10 != 9;", [Token(INT, "10"), T(NOT_EQ), Token(INT, "9"), T(SEMICOLON), T(EOF)])