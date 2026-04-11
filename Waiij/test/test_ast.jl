using Waiij

println("Running ast tests...")

program = Program([
    LetStatement(
        Token(LET, "let"),
        Identifier(
            Token(IDENT, "myVar"),
            "myVar"
        ),
        Identifier(
            Token(IDENT, "anotherVar"),
            "anotherVar"
        )
    )
])
program_string = to_string(program)
@assert program_string == "let myVar = anotherVar;"