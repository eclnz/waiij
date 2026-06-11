@testitem "Parser: let statements" begin
    using Waiij

    function is_let_statement(statement, identifier)
        @assert token_literal(statement) == "let" "Expected token_literal == \"let\", got $(token_literal(statement))"
        @assert statement isa LetStatement "Expected statement to be LetStatement, got $(typeof(statement))"
        @assert statement.name.value == identifier "Expected name.value == $(identifier), got $(statement.name.value)"
        return true
    end

    p = Parser("""
        let x = 5;
        let y = 10;
        let foobar = 838383;
    """)
    program = parse_program!(p)
    @test program !== nothing
    @test length(program.statements) == 3
    for (stmt, id) in zip(program.statements, ["x", "y", "foobar"])
        @test is_let_statement(stmt, id)
    end
end

@testitem "Parser: return statements" begin
    using Waiij

    p = Parser("""
        return 5;
        return 10;
        return 993322;
    """)
    program = parse_program!(p)
    @test program !== nothing
    @test length(program.statements) == 3
    for stmt in program.statements
        @test token_literal(stmt) == "return"
        @test stmt isa ReturnStatement
    end
end

@testitem "Parser: let statement errors" begin
    using Waiij

    p = Parser("""
        let x 5;
        let = 10;
        let 838383;
    """)
    parse_program!(p)
    expected = [
        "expected next token to be: =, got INT",
        "expected next token to be: IDENT, got =",
        "expected next token to be: IDENT, got INT"
    ]
    @test length(p.errors) == length(expected)
    for (err, msg) in zip(p.errors, expected)
        @test err == msg
    end
end

@testitem "Parser: identifier expression" begin
    using Waiij

    p = Parser("foobar;")
    program = parse_program!(p)
    @test length(p.errors) == 0
    statements = filter(stmt -> !(stmt isa ErrorStatement), program.statements)
    @test length(statements) == 1
    statement = statements[1]
    @test statement isa ExpressionStatement
    @test statement.expression isa Identifier
    @test statement.expression.value == "foobar"
end
