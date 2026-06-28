export Node
export Program 
export Identifier 
export Expression, IntegerLiteral, PrefixExpression, InfixExpression, BooleanLiteral 
export Statement, ExpressionStatement, LetStatement, ReturnStatement
export token_literal, to_string

abstract type Node end
abstract type Statement <: Node end
abstract type Expression <: Node end

## Expression
# ----------------------------------------------------
struct Identifier <: Expression
    token::Token
    value::String
end
to_string(i::Identifier) = i.value

# ----------------------------------------------------
struct IntegerLiteral <: Expression
    token::Token
    value::Int
end

token_literal(il::IntegerLiteral)::String = il.token.literal
to_string(il::IntegerLiteral)::String = il.token.literal

# ----------------------------------------------------
struct BooleanLiteral <: Expression
    token::Token
    value::Bool
end

token_literal(bl::BooleanLiteral)::String = bl.token.literal
to_string(bl::BooleanLiteral)::String = bl.token.literal

# ----------------------------------------------------
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

# ----------------------------------------------------
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

## Statement
# ----------------------------------------------------
struct LetStatement <: Statement
    token::Token
    name::Identifier
    value::Expression
end

function to_string(s::LetStatement)
    out = IOBuffer()
    write(out, token_literal(s) * " ")
    write(out, to_string(s.name))
    write(out, " = ")
    write(out, to_string(s.value))
    write(out, ";")
    return String(take!(out))
end

# ----------------------------------------------------
struct ReturnStatement <: Statement
    token::Token
    return_value::Expression
end

# ----------------------------------------------------
struct ExpressionStatement <: Statement
    token::Token
    expression::Expression
end

token_literal(s::Union{LetStatement, ReturnStatement, ExpressionStatement}) = s.token.literal
to_string(e::ExpressionStatement) = to_string(e.expression)

# ----------------------------------------------------
struct Program
    statements::Vector{Statement}
end

Program() = Program(Vector{Statement}())

function to_string(program::Program)
    out = IOBuffer()
    write(out, join([to_string(stmt) for stmt in program.statements]))
    return String(take!(out))
end