using Waiij

function is_let_statement(statement, identifier)
    @assert token_literal(statement) == "let" "Expected token_literal == \"let\", got $(token_literal(statement))"
    @assert statement isa LetStatement "Expected statement to be LetStatement, got $(typeof(statement))"
    @assert statement.name.value == identifier "Expected name.value == $(identifier), got $(statement.name.value)"
    return true
end

function is_return_statement(statement, _)
    @assert token_literal(statement) == "return" "Expected token_literal == \"return\", got $(token_literal(statement))"
    @assert statement isa ReturnStatement "Expected statement to be ReturnStatement, got $(typeof(statement))"
    return true
end

function test_parse_statements(statements::String, n_statements::Int, expected_identifiers::Vector{String}, is_correct::Function)
    p = Parser(statements)
    program = parse_program!(p)
    @assert program !== nothing "Expected a Program, got nothing"
    @assert length(program.statements) == n_statements "Expected $(n_statements) statements, got $(length(program.statements))"
    for (stmt, id) in zip(program.statements, expected_identifiers)
        @assert is_correct(stmt, id)
    end
    print(to_string(program))
end

function test_parse_statement_errors(statements::String, messages::Vector{String})
    p = Parser(statements)
    program = parse_program!(p)
    @assert length(p.errors) == length(messages) "Expected parser to have $(length(messages)) errors, but it had $(length(p.errors))"
    for (err, msg) in zip(p.errors, messages)
        @assert err == msg "Expected error: \"$msg\", got: \"$err\""
    end
end

test_parse_statements(
    """
    let x = 5;
    let y = 10;
    let foobar = 838383;
    """,
    3,
    ["x", "y", "foobar"],
    is_let_statement
)

test_parse_statements(
    """
    return 5;
    return 10;
    return 993322;
    """,
    3,
    ["return", "return", "return"],
    is_return_statement
)

test_parse_statement_errors(
    """
    let x 5;
    let = 10;
    let 838383;
    """, # we dont have a semicolon after the second or third statement. We should be catching things and erroring when there is no semicolon
    [
        "expected next token to be: =, got INT",
        "expected next token to be: IDENT, got =",
        "expected next token to be: IDENT, got INT"
    ]
)

