@testitem "AST: to_string" begin
    using Waiij
    program = Program([
        LetStatement(
            Token(LET, "let"),
            Identifier(Token(IDENT, "myVar"), "myVar"),
            Identifier(Token(IDENT, "anotherVar"), "anotherVar")
        )
    ])
    @test to_string(program) == "let myVar = anotherVar;"
end
