export start

const PROMPT = ">> "

function start()
    print(PROMPT)
    for line in eachline(stdin)
        p = Parser(line)
        program = parse_program!(p)

        if length(p.errors) > 0
            for error in p.errors
                println(error)
            end
        else
            for statement in program.statements
                println(statement)
            end
        end
        print(PROMPT)
    end
end



