@testitem "Parser: let statements" begin
    using Waiij

    function is_let_statement(statement, identifier)
        @test token_literal(statement) == "let"
        @test statement isa LetStatement
        @test statement.name.value == identifier
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

@testsnippet ExprHelpers begin
    using Waiij
    function test_int_literal(expr, value::Int)
        @test expr isa IntegerLiteral
        @test expr.value isa Int
        @test expr.value == value
    end
end

@testitem "Parser: integer literal" setup=[ExprHelpers] begin
    using Waiij

    p = Parser("5;")
    program = parse_program!(p)
    @test length(p.errors) == 0
    @test length(program.statements) == 1
    statement = program.statements[1]
    @test statement isa ExpressionStatement
    literal = statement.expression
    test_int_literal(literal, 5)
end

@testitem "Parser: prefix operators" setup=[ExprHelpers] begin
    using Waiij

    struct PrefixTest
        input::String
        operator::String
        integer_value::Int
    end
    prefix_tests = [
        # PrefixTest("!5;", "!", 5)
        PrefixTest("-15;", "-", 15)
    ]

    function test_prefix(prefix::PrefixTest)
        p = Parser(prefix.input)
        program = parse_program!(p)
        @test length(p.errors) == 0
        @test length(program.statements) == 1
        statement = program.statements[1]
        @test statement isa ExpressionStatement
        expr = statement.expression
        @test expr isa PrefixExpression
        @test expr.operator == prefix.operator
        test_int_literal(expr.right, prefix.integer_value)
    end

    for prefix in prefix_tests
        test_prefix(prefix)
    end
end

@testitem "Parser: infix operators" setup=[ExprHelpers] begin
    struct InfixTest
        input::String
        left_value::Int
        operator::String
        right_value::Int
    end
    infix_tests = [
        InfixTest("5 + 5", 5, "+", 5)
        InfixTest("5 - 5", 5, "-", 5)
        InfixTest("5 * 5", 5, "*", 5)
        InfixTest("5 / 5", 5, "/", 5)
        InfixTest("5 > 5", 5, ">", 5)
        InfixTest("5 < 5", 5, "<", 5)
        InfixTest("5 == 5", 5, "==", 5)
        InfixTest("5 != 5", 5, "!=", 5)
    ]

    function test_infix(infix::InfixTest)
        p = Parser(infix.input)
        program = parse_program!(p)
        @test length(p.errors) == 0
        @test length(program.statements) == 1
        statement = program.statements[1]
        @test statement isa ExpressionStatement
        expression = statement.expression
        @test expression isa InfixExpression
        test_int_literal(expression.left, infix.left_value)
        @test expression.operator == infix.operator
        test_int_literal(expression.right, infix.right_value)

    end
    for infix in infix_tests
        test_infix(infix)
    end
end

@testitem "Parser: operator precedence" begin
    using Waiij

    precedence_tests = [
        ("-a * b", "((-a) * b)")
        ("!-a", "(!(-a))")
        ("a + b + c", "((a + b) + c)")
        ("a + b - c", "((a + b) - c)")
        ("a * b * c", "((a * b) * c)")
        ("a * b / c", "((a * b) / c)")
        ("a + b / c", "(a + (b / c))")
        ("a + b * c + d / e - f", "(((a + (b * c)) + (d / e)) - f)")
        ("3 + 4; -5 * 5", "(3 + 4)((-5) * 5)")
        ("5 > 4 == 3 < 4", "((5 > 4) == (3 < 4))")
        ("5 < 4 != 3 > 4", "((5 < 4) != (3 > 4))")
        ("3 + 4 * 5 == 3 * 1 + 4 * 5", "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))")
    ]

    for (input, expected) in precedence_tests
        p = Parser(input)
        program = parse_program!(p)
        @test length(p.errors) == 0
        @test to_string(program) == expected
    end
end