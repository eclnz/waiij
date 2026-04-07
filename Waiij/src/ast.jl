export Node, Statement, Expression, Program, Identifier, LetStatement, token_literal

abstract type Node end
abstract type Statement <: Node end
abstract type Expression <: Node end

token_literal(n::Node) = error("token_literal not implemented for $(typeof(n))")

struct Program <: Node
    statements::Vector{Statement}
end

Program() = Program(Statement[])

function token_literal(p::Program)
    if !isempty(p.statements)
        token_literal(p.statements[1])
    else
        ""
    end
end

struct Identifier <: Expression
    token::Token
    value::String
end

token_literal(i::Identifier) = i.token.literal

struct LetStatement <: Statement
    token::Token
    name::Identifier
    value::Union{Expression, Nothing}
end

token_literal(ls::LetStatement) = ls.token.literal