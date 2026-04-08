export Node, Statement, Expression, Program, Identifier, LetStatement, ReturnStatement, token_literal

# abstract type Node end
# abstract type Statement <: Node end
# abstract type Expression <: Node end

struct Identifier
    token::Token
    value::String
end

Expression = Identifier

struct LetStatement
    token::Token
    name::Identifier
    value::Union{Expression, Nothing}
end

struct ReturnStatement
    token::Token
    return_value::Union{Expression, Nothing}
end

struct ExpressionStatement
    token::Token
    expression:: Expression
end

Statement = Union{LetStatement, ReturnStatement, ExpressionStatement}
token_literal(s::Statement) = s.token.literal

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