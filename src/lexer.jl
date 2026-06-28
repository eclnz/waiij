export Lexer, next_token!

mutable struct Lexer
    input::String
    position::Int    # current position in input (1-based, points to current char)
    read_position::Int # current reading position in input (1-based, after current char)
    char::Char        # current char under examination
end

function Lexer(input::String)::Lexer
    l = Lexer(input, 1, 1, EOF_CHAR)
    readchar!(l)
    return l
end

function readchar!(l::Lexer)
    if l.read_position > lastindex(l.input)
        l.char = EOF_CHAR
    else
        l.char = l.input[l.read_position]
    end
    l.position = l.read_position
    l.read_position += 1
end

function peekchar(l::Lexer)
    if l.read_position > lastindex(l.input)
        return EOF_CHAR
    else
        return l.input[l.read_position]
    end
end

function skip_whitespace!(l::Lexer)
    while l.char in WHITESPACE_CHARS 
        readchar!(l)
    end
end

function isletter_(char::Char)
     return isletter(char) || char == '_'
 end

function readfromlexer!(l::Lexer, continue_check::Function)
    start = l.position
    while continue_check(l.char)
        readchar!(l)
    end
    return l.input[start:(l.position-1)]
end

read_identifier!(l::Lexer) = readfromlexer!(l, isletter_)
read_number!(l::Lexer) = readfromlexer!(l, isdigit)

function lookup_ident_type(literal::String)
    return get(KW_TOKENS, literal, IDENT)
end

function lookup_char_type(char::Char)
    return get(CHAR_TOKENS, char, ILLEGAL)
end

function read_char_token!(l::Lexer)
    type = lookup_char_type(l.char)
    if type == ASSIGN && peekchar(l) == ASSIGN_CHAR
        tok = Token(EQ)
        readchar!(l) 
    elseif type == BANG && peekchar(l) == ASSIGN_CHAR
        tok = Token(NOT_EQ)
        readchar!(l)
    else
        tok = Token(type, string(l.char))
    end
    readchar!(l)
    return tok
end

function next_token!(l::Lexer)
    skip_whitespace!(l)
    if l.char == EOF_CHAR
        return Token(EOF, token_literal(EOF))
    elseif isletter(l.char)
        literal = read_identifier!(l)
        type = lookup_ident_type(literal)
        return Token(type, literal)
    elseif isdigit(l.char)
        literal = read_number!(l)
        return Token(INT, literal)
    else
        return read_char_token!(l)
    end
end