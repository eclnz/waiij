export Node, Statement, Expression, Program, Identifier, ExpressionStatement, LetStatement, ReturnStatement, ErrorStatement, token_literal

abstract type Node end
abstract type Statement <: Node end

struct Expression <: Node end

struct Identifier <: Node
    token::Token
    value::String
end

struct LetStatement <: Statement
    token::Token
    name::Identifier
    value::Expression
end

struct ReturnStatement <: Statement
    token::Token
    return_value::Expression
end

struct ExpressionStatement <: Statement
    token::Token
    expression::Expression
end

struct ErrorStatement <: Statement
    token::String
end

token_literal(s::Union{LetStatement, ReturnStatement, ExpressionStatement}) = s.token.literal
token_literal(s::ErrorStatement) = s.token

struct Program
    statements::Vector{Statement}
end

Program() = Program(Vector{Statement}())

function token_literal(p::Program)
    if !isempty(p.statements)
        token_literal(p.statements[1])
    else
        ""
    end
end