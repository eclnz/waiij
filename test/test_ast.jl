@testsnippet AstHelpers begin
    using Waiij

    ident(name::String) = Identifier(Token(IDENT, name), name)
end

@testitem "AST: to_string" setup=[AstHelpers] begin
    program = Program([
        LetStatement(Token(LET, "let"), ident("myVar"), ident("anotherVar"))
    ])
    @test to_string(program) == "let myVar = anotherVar;"
end
