using Waiij

function is_let_statement(statement, identifier)
    @assert token_literal(statement) == "let" "Expected token_literal == \"let\", got $(token_literal(statement))"
    @assert statement isa LetStatement "Expected statement to be LetStatement, got $(typeof(statement))"
    @assert statement.name.value == identifier "Expected name.value == $(identifier), got $(statement.name.value)"
    return true
end

function check_parser_errors(statements::String, messages::Vector{String})
    p = Parser(statements)
    program = parse_program!(p)
    @assert length(p.errors) == length(messages) "Expected parser to have $(length(messages)) errors, but it had $(length(p.errors))"
end

function check_let_statements(statements::String, n_statements::Int, expected_identifiers::Vector{String})
    p = Parser(statements)
    program = parse_program!(p)
    @assert program !== nothing "Expected a Program, got nothing"
    @assert length(program.statements) == n_statements "Expected $(n_statements) statements, got $(length(program.statements))"
    for (stmt, id) in zip(program.statements, expected_identifiers)
        @assert is_let_statement(stmt, id)
    end
end

check_let_statements(
    """
    let x = 5;
    let y = 10;
    let foobar = 838383;
    """,
    3,
    ["x", "y", "foobar"]
)

check_parser_errors(
    """
    let x 5;
    let = 10
    let 838383
    """,
    [
        "expected next token to be: =, got INT",
        "expected next token to be: IDENT, got =",
        "expected next token to be: IDENT, got INT"
    ]
)