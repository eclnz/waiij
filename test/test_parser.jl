@testsnippet ParserHelpers begin
    using Waiij

    function parse_input(input::String; expect_errors::Int=0)
        p = Parser(input)
        program = parse_program!(p)
        @test length(p.errors) == expect_errors
        return p, program
    end

    function parse_single_expression(input::String)
        _, program = parse_input(input)
        @test length(program.statements) == 1
        statement = program.statements[1]
        @test statement isa ExpressionStatement
        return statement.expression
    end

    function test_literal(expr, value::Int)
        @test expr isa IntegerLiteral
        @test expr.value isa Int
        @test expr.value == value
    end
    function test_literal(expr, value::Bool)
        @test expr isa BooleanLiteral
        @test expr.value isa Bool
        @test expr.value == value
    end
    function test_literal(expr, value::String)
        @test expr isa Identifier
        @test expr.value == value
    end

    abstract type ExprTest end
    test_expr(test::ExprTest) = test_expr(parse_single_expression(test.input), test)

    struct InfixTest <: ExprTest
        input
        left_value
        operator::String
        right_value
    end

    function test_expr(expression, test::InfixTest)
        @test expression isa InfixExpression
        @test expression.operator == test.operator
        test_literal(expression.left, test.left_value)
        test_literal(expression.right, test.right_value)
    end

    struct PrefixTest <: ExprTest
        input::String
        operator::String
        value
    end

    function test_expr(expression, test::PrefixTest)
        @test expression isa PrefixExpression
        @test expression.operator == test.operator
        test_literal(expression.right, test.value)
    end
end

@testitem "Parser: let statements" setup=[ParserHelpers] begin
    function is_let_statement(statement, identifier)
        @test token_literal(statement) == "let"
        @test statement isa LetStatement
        @test statement.name.value == identifier
        return true
    end

    _, program = parse_input("""
        let x = 5;
        let y = 10;
        let foobar = 838383;
    """)
    @test length(program.statements) == 3
    for (stmt, id) in zip(program.statements, ["x", "y", "foobar"])
        @test is_let_statement(stmt, id)
    end
end

@testitem "Parser: return statements" setup=[ParserHelpers] begin
    _, program = parse_input("""
        return 5;
        return 10;
        return 993322;
    """)
    @test length(program.statements) == 3
    for stmt in program.statements
        @test token_literal(stmt) == "return"
        @test stmt isa ReturnStatement
    end
end

@testitem "Parser: let statement errors" setup=[ParserHelpers] begin
    p, _ = parse_input("""
        let x 5;
        let = 10;
        let 838383;
    """; expect_errors=3)
    expected = [
        "expected next token to be: =, got INT",
        "expected next token to be: IDENT, got =",
        "expected next token to be: IDENT, got INT"
    ]
    for (err, msg) in zip(p.errors, expected)
        @test err == msg
    end
end

@testitem "Parser: identifier expression" setup=[ParserHelpers] begin
    test_literal(parse_single_expression("foobar;"), "foobar")
end

@testitem "Parser: integer literal" setup=[ParserHelpers] begin
    test_literal(parse_single_expression("5;"), 5)
end

@testitem "Parser: boolean literal" setup=[ParserHelpers] begin
    test_literal(parse_single_expression("true;"), true)
end

@testitem "Parser: prefix operators" setup=[ParserHelpers] begin
    prefix_tests = [
        PrefixTest("!5;", "!", 5)
        PrefixTest("-15;", "-", 15)
        PrefixTest("!true;", "!", true)
        PrefixTest("!false;", "!", false)
    ]

    for prefix in prefix_tests
        test_expr(prefix)
    end
end

@testitem "Parser: infix operators" setup=[ParserHelpers] begin
    infix_tests = [
        InfixTest("5 + 5", 5, "+", 5)
        InfixTest("5 - 5", 5, "-", 5)
        InfixTest("5 * 5", 5, "*", 5)
        InfixTest("5 / 5", 5, "/", 5)
        InfixTest("5 > 5", 5, ">", 5)
        InfixTest("5 < 5", 5, "<", 5)
        InfixTest("5 == 5", 5, "==", 5)
        InfixTest("5 != 5", 5, "!=", 5)
        InfixTest("true == true", true, "==", true)
        InfixTest("true != false", true, "!=", false)
        InfixTest("false == false", false, "==", false)
    ]

    for infix in infix_tests
        test_expr(infix)
    end
end

@testitem "Parser: operator precedence" setup=[ParserHelpers] begin
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
        ("true", "true")
        ("false", "false")
        ("3 > 5 == false", "((3 > 5) == false)")
        ("3 < 5 == true", "((3 < 5) == true)")
        ("1  + (2 + 3) + 4", "((1 + (2 + 3)) + 4)")
        ("(5 + 5) * 2", "((5 + 5) * 2)")
        ("2 / (5 + 5)", "(2 / (5 + 5))")
        ("-(5 + 5)", "(-(5 + 5))")
        ("!(true == true)", "(!(true == true))")
    ]

    for (input, expected) in precedence_tests
        _, program = parse_input(input)
        @test to_string(program) == expected
    end
end

@testitem "Parser: if statement" setup=[ParserHelpers] begin
    expression = parse_single_expression("if (x > y) { x }")
    @test expression isa IfExpression

    test_expr(expression.condition, InfixTest("x > y", "x", ">", "y"))

    @test length(expression.consequence.statements) == 1
    consequence = expression.consequence.statements[1]
    @test consequence isa ExpressionStatement
    test_literal(consequence.expression, "x")
end

@testitem "Parser: function literal" begin
    p = Parser("fn(x, y) { x + y; }")
    program = parse_program!(p)

end
