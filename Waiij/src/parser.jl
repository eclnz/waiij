export Parser, next_token!, parse_program!

mutable struct Parser
    l::Lexer
    cur_token::Token
    peek_token::Token
    errors::Vector{String}
end

function Parser(l::Lexer)
    placeholder_token = Token(EOF, EOF) # These are immediately written over.
    p = Parser(l, placeholder_token, placeholder_token, String[])
    next_token!(p)
    next_token!(p)
    return p
end

function Parser(input::String)
    Parser(Lexer(input))
end

function errors(p::Parser)
    return p.errors
end

function peek_error!(p::Parser, t::String)
    msg = "expected next token to be: $(t), got $(p.peek_token.type)"
    push!(p.errors, msg)
end

function next_token!(p::Parser)
    p.cur_token = p.peek_token
    p.peek_token = next_token!(p.l)
end

cur_token_is(p::Parser, t::String) = p.cur_token.type == t
peek_token_is(p::Parser, t::String) = p.peek_token.type == t

function expect_peek!(p::Parser, t::String)
    if peek_token_is(p, t)
        next_token!(p)
        return true
    else 
        peek_error!(p, t)
        return false
    end
end

function to_semicolon!(p::Parser)
    while !cur_token_is(p, SEMICOLON) && !cur_token_is(p, EOF)
        next_token!(p)
    end
end

function parse_let_statement!(p::Parser)
    let_token = p.cur_token
    if !expect_peek!(p, IDENT)
        return nothing
    end
    s_name = Identifier(p.cur_token, p.cur_token.literal)
    if !expect_peek!(p, ASSIGN)
        return nothing
    end
    to_semicolon!(p)
    # TODO: We're skipping expressions until we hit a semicolon
    return LetStatement(let_token, s_name, nothing)
end

function parse_return_statement(p::Parser)
    cur_token = p.cur_token
    next_token!(p)
    to_semicolon!(p)
    return ReturnStatement(cur_token, nothing)
end

function parse_statement!(p::Parser)
    if p.cur_token.type == LET
        return parse_let_statement!(p)
    elseif p.cur_token.type == RETURN
        return parse_return_statement(p)
    else
        return nothing
    end
end

function parse_program!(p::Parser)
    program = Program()
    while p.cur_token.type != EOF
        statement = parse_statement!(p)
        if statement !== nothing
            push!(program.statements, statement)
        end
        next_token!(p)
    end
    return program
end
