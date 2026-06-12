export Node, Statement, Expression, Program, Identifier, ExpressionStatement, LetStatement, ReturnStatement, token_literal, IntegerLiteral, PrefixExpression, InfixExpression, to_string

abstract type Node end
abstract type Statement <: Node end

abstract type Expression <: Node end

struct Identifier <: Expression
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

token_literal(s::Union{LetStatement, ReturnStatement, ExpressionStatement}) = s.token.literal

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

struct IntegerLiteral <: Expression
    token::Token
    value::Int
end

struct PrefixExpression <: Expression
    token::Token
    operator::String
    right::Expression
end

token_literal(pe::PrefixExpression)::String = pe.token.literal
function to_string(pe::PrefixExpression)::String
    out = IOBuffer()
    write(out, "(")
    write(out, pe.operator)
    write(out, to_string(pe.right))
    write(out, ")")
    return String(take!(out))
end

struct InfixExpression <: Expression
    token::Token
    left::Expression
    operator:: String
    right:: Expression
end

token_literal(ie::InfixExpression)::String = ie.token.literal
function to_string(ie::InfixExpression)::String
    out = IOBuffer()
    write(out, "(")
    write(out, to_string(ie.left))
    write(out, " " * ie.operator * " ")
    write(out, to_string(ie.right))
    write(out, ")")
    return String(take!(out))
end

# Helpers -------------------

function to_string(program::Program)
    out = IOBuffer()
    write(out, join([to_string(stmt) for stmt in program.statements]))
    return String(take!(out))
end

to_string(i::Identifier) = i.value

function to_string(s::LetStatement)
    out = IOBuffer()
    write(out, token_literal(s) * " ")
    write(out, to_string(s.name))
    write(out, " = ")
    write(out, to_string(s.value))
    write(out, ";")
    return String(take!(out))
end

to_string(e::Expression) = "NA_expr"

function to_string(s::ReturnStatement)
    out = IOBuffer()
    write(out, token_literal(s) * " ")
    write(out, to_string(s.return_value))
    write(out, ";")
    return String(take!(out))
end

function to_string(e::ExpressionStatement)
    return to_string(e.expression)
end

token_literal(il::IntegerLiteral)::String = il.token.literal
to_string(il::IntegerLiteral)::String = il.token.literal
