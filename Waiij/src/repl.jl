export start

const PROMPT = ">> "

function start()
    print(PROMPT)
    for line in eachline(stdin)
        print(PROMPT)
        l = Lexer(line)
        token = next_token(l)
        while token.type != EOF
            println(token)
            token = next_token(l)
        end
    end
end