include("token.jl")

mutable struct Lexer
    input::String
    position::Int    # current position in input (1-based, points to current char)
    read_position::Int # current reading position in input (1-based, after current char)
    char::Char        # current char under examination
end

function read_char!(l::Lexer)
    if l.read_position > lastindex(l.input)
        l.char = '\0'
    else
        l.char = l.input[l.read_position]
    end
    l.position = l.read_position
    l.read_position += 1
end

function skip_whitespace!(l::Lexer)
    while l.char in [' ', '\t', '\n', '\r']
        read_char!(l)
    end
end

function isletter_(char::Char)
     return isletter(char) || char == '_'
 end

# TODO: These could be abstracted a little.
function read_identifier!(l::Lexer)::String
    start = l.position
    while isletter_(l.char)
        read_char!(l)
    end
    # read_identifier! stops once l.char is not valid, so l.position is at first non-letter
    return l.input[start:(l.position-1)]
end

function read_number!(l::Lexer)
    start = l.position
    while isdigit(l.char)
        read_char!(l)
    end
    return l.input[start:(l.position-1)]
end

function lookup_ident(lit::String)
    kw_tokens = Dict(
        "fn" => FUNCTION,
        "let" => LET,
        "if" => IF,
        "return" => RETURN
    )
    return get(kw_tokens, lit, IDENT)
end

function next_token(l::Lexer)
    skip_whitespace!(l)

    if isletter(l.char)
        literal = read_identifier!(l)
        type_ = lookup_ident(literal)
        return Token(type_, literal)
    elseif isdigit(l.char)
        literal = read_number!(l)
        return Token(INT, literal)
    end

    c = l.char
    if c == '='
        tok = Token(ASSIGN, "=")
    elseif c == ';'
        tok = Token(SEMICOLON, ";")
    elseif c == '('
        tok = Token(LPAREN, "(")
    elseif c == ')'
        tok = Token(RPAREN, ")")
    elseif c == ','
        tok = Token(COMMA, ",")
    elseif c == '+'
        tok = Token(PLUS, "+")
    elseif c == '{'
        tok = Token(LBRACE, "{")
    elseif c == '}'
        tok = Token(RBRACE, "}")
    elseif c == '\0'
        tok = Token(EOF, "")
    else
        tok = Token(ILLEGAL, string(c))
    end
    read_char!(l)
    return tok
end

function new(input::String)::Lexer
    l = Lexer(input, 1, 1, '\0')
    read_char!(l)
    return l
end