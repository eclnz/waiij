export Lexer, next_token

mutable struct Lexer
    input::String
    position::Int    # current position in input (1-based, points to current char)
    read_position::Int # current reading position in input (1-based, after current char)
    char::Char        # current char under examination
end

function Lexer(input::String)::Lexer
    l = Lexer(input, 1, 1, '\0')
    readchar!(l)
    return l
end

function readchar!(l::Lexer)
    if l.read_position > lastindex(l.input)
        l.char = '\0'
    else
        l.char = l.input[l.read_position]
    end
    l.position = l.read_position
    l.read_position += 1
end

function peekchar(l::Lexer)
    if l.read_position > lastindex(l.input)
        return '\0'
    else
        return l.input[l.read_position]
    end
end

function skip_whitespace!(l::Lexer)
    while l.char in [' ', '\t', '\n', '\r']
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

function next_token(l::Lexer)
    skip_whitespace!(l)
    
    if l.char == '\0'
        readchar!(l)
        return Token(EOF, EOF)
    elseif isletter(l.char)
        literal = read_identifier!(l)
        type_ = lookup_ident_type(literal)
        return Token(type_, literal)
    elseif isdigit(l.char)
        literal = read_number!(l)
        return Token(INT, literal)
    end
    
    type = lookup_char_type(l.char)
    if type == ASSIGN && peekchar(l) == '='
        tok = Token(EQ, EQ)
        readchar!(l) 
    elseif type == BANG && peekchar(l) == '='
        tok = Token(NOT_EQ, NOT_EQ)
        readchar!(l)
    else
        tok = Token(type, string(l.char))
    end
    readchar!(l)
    return tok
end