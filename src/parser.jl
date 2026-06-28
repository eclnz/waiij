export Parser, next_token!, parse_program!

const PrefixParseFn = Function  # () -> Expression
const InfixParseFn = Function   # (Expression) -> Expression

mutable struct Parser
    l::Lexer
    cur_token::Token
    peek_token::Token
    errors::Vector{String}
    prefix_parse_fns::Dict{TokenType, PrefixParseFn}
    infix_parse_fns::Dict{TokenType, InfixParseFn}
end

function parse_identifier(p::Parser)::Identifier
    return Identifier(p.cur_token, p.cur_token.literal)
end

function parse_int_literal(p::Parser)
    value = tryparse(Int, p.cur_token.literal)
    if isnothing(value)
        push!(p.errors, "could not parse $(p.cur_token.literal) as integer")
        return nothing
    end
    return IntegerLiteral(p.cur_token, value)
end

function parse_prefix_expr(p::Parser)
    token = p.cur_token
    operator = p.cur_token.literal
    next_token!(p)
    right = parse_expression(p, PREFIX)
    if isnothing(right)
        return nothing
    end
    return PrefixExpression(token, operator, right)
end

function parse_infix_expr!(p::Parser, left)
    token = p.cur_token
    operator = p.cur_token.literal
    precedence = cur_precedence(p)
    next_token!(p)
    right = parse_expression(p, precedence)
    if isnothing(right)
        return nothing
    end
    return InfixExpression(token, left, operator, right)
end
 
const PRECEDENCES = Dict(
    EQ => EQUALS,
    NOT_EQ => EQUALS,
    LT => LESSGREATER,
    GT => LESSGREATER,
    PLUS => SUM,
    MINUS => SUM,
    SLASH => PRODUCT,
    ASTERIK => PRODUCT
)

peek_precedence(p::Parser) = get(PRECEDENCES, p.peek_token.type, LOWEST)
cur_precedence(p::Parser)  = get(PRECEDENCES, p.cur_token.type,  LOWEST)

function register_prefixes!(p)
    register_prefix(p, IDENT, parse_identifier)
    register_prefix(p, INT, parse_int_literal)
    register_prefix(p, BANG, parse_prefix_expr)
    register_prefix(p, MINUS, parse_prefix_expr)
end

function register_infixes!(p)
    register_infix(p, PLUS, parse_infix_expr!)
    register_infix(p, MINUS, parse_infix_expr!)
    register_infix(p, SLASH, parse_infix_expr!)
    register_infix(p, ASTERIK, parse_infix_expr!)
    register_infix(p, EQ, parse_infix_expr!)
    register_infix(p, NOT_EQ, parse_infix_expr!)
    register_infix(p, LT, parse_infix_expr!)
    register_infix(p, GT, parse_infix_expr!)
end

function Parser(l::Lexer)
    placeholder_token = Token(EOF) # These are immediately written over.
    p = Parser(l, placeholder_token, placeholder_token, String[], Dict{TokenType, PrefixParseFn}(), Dict{TokenType, InfixParseFn}())
    register_prefixes!(p)
    register_infixes!(p)
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

function peek_error!(p::Parser, t::TokenType)
    msg = "expected next token to be: $(token_literal(t)), got $(token_literal(p.peek_token.type))"
    push!(p.errors, msg)
end

function next_token!(p::Parser)
    p.cur_token = p.peek_token
    p.peek_token = next_token!(p.l)
end

cur_token_is(p::Parser, t::TokenType) = p.cur_token.type == t
peek_token_is(p::Parser, t::TokenType) = p.peek_token.type == t

function expect_peek!(p::Parser, t::TokenType)::Bool
    if peek_token_is(p, t)
        next_token!(p)
        return true
    else 
        peek_error!(p, t)
        return false
    end
end

function to_semicolon!(p::Parser)::Nothing
    while !cur_token_is(p, SEMICOLON) && !cur_token_is(p, EOF)
        next_token!(p)
    end
end

function parse_let_statement!(p::Parser)
    let_token = p.cur_token
    if !expect_peek!(p, IDENT)
        to_semicolon!(p)
        return nothing
    end
    s_name = Identifier(p.cur_token, p.cur_token.literal)
    if !expect_peek!(p, ASSIGN)
        to_semicolon!(p)
        return nothing
    end
    to_semicolon!(p)
    # TODO: We're skipping expressions until we hit a semicolon
    return LetStatement(let_token, s_name, s_name) # TODO: Update value?
end

function parse_return_statement(p::Parser)
    cur_token = p.cur_token
    next_token!(p)
    to_semicolon!(p)
    return ReturnStatement(cur_token, Identifier(cur_token, cur_token.literal))
end

function parse_expression(p::Parser, precedence::Int)
    if !haskey(p.prefix_parse_fns, p.cur_token.type)
        push!(p.errors, "no prefix parse function for $(p.cur_token.type) found")
        return nothing
    end
    left_expr = p.prefix_parse_fns[p.cur_token.type](p)

    while !isnothing(left_expr) && !peek_token_is(p, SEMICOLON) && precedence < peek_precedence(p)
        if !haskey(p.infix_parse_fns, p.peek_token.type)
            return left_expr
        end
        infix = p.infix_parse_fns[p.peek_token.type]
        next_token!(p)
        left_expr = infix(p, left_expr)
    end

    return left_expr
end

function parse_expression_statement(p::Parser)
    expression = parse_expression(p, LOWEST)
    if isnothing(expression)
        return nothing
    end
    statement = ExpressionStatement(p.cur_token, expression)
    if peek_token_is(p, SEMICOLON)
        next_token!(p)
    end
    return statement
end

function parse_statement!(p::Parser)::Union{Statement, Nothing}
    if p.cur_token.type == LET
        return parse_let_statement!(p)
    elseif p.cur_token.type == RETURN
        return parse_return_statement(p)
    else
        return parse_expression_statement(p)
    end
end

function parse_program!(p::Parser)
    program = Program()
    while p.cur_token.type != EOF
        statement = parse_statement!(p)
        if !isnothing(statement)
            push!(program.statements, statement)
        end
        next_token!(p)
    end
    return program
end

function register_prefix(p::Parser, token_type::TokenType, fn::Function)
    p.prefix_parse_fns[token_type] = fn
end

function register_infix(p::Parser, token_type::TokenType, fn::Function)
    p.infix_parse_fns[token_type] = fn
end