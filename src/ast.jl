export Node
export Program 
export Identifier 
export Expression, IntegerLiteral, PrefixExpression, InfixExpression, BooleanLiteral, IfExpression
export Statement, ExpressionStatement, LetStatement, ReturnStatement, BlockStatement
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

# ----------------------------------------------------
struct BlockStatement <: Statement
    token:: Token
    statements::Vector{Statement}
end

token_literal(bs::BlockStatement) = bs.token.literal
function to_string(bs::BlockStatement)
    out = IOBuffer()
    for statement in bs.statements
        write(out, to_string(statement))
    end
    return String(take!(out))
end

# ---------------------------------------------------
struct IfExpression <: Expression
    token::Token
    condition::Expression
    consequence::BlockStatement 
    alternative::Union{BlockStatement, Nothing}
end

token_literal(ie::IfExpression) = ie.token.literal
function to_string(ie::IfExpression)::String
    out = IOBuffer()
    write(out, "(")
    write(out, to_string(ie.condition))
    write(out, " ")
    write(out, to_string(ie.consequence))
    if !isnothing(ie.consequence)
        write(out, "else")
        write(out, to_string(ie.consequence))
    end
    return String(take!(out))
end

# ---------------------------------------------------
struct FunctionLiteral <: Expression
    token::Token
    params::Vector{Identifier}
    body::BlockStatement
end

token_literal(fl::FunctionLiteral) = fl.token.literal
function to_string(fl::FunctionLiteral)::String
    out = IOBuffer()
    params = [to_string(param) for param in fl.params]
    write(out, "(")
    write(out, join(params, ", "))
    write(out, ")")
    write(out, to_string(fl.body))
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


## Program
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