module Waiij

include("token.jl")
include("lexer.jl")
include("ast.jl")
include("parser.jl")
include("repl.jl")

function main()
    username = get(ENV, "USER", get(ENV, "USERNAME", "User"))
    println("Hello $(username)! This is the Monkey programming language!")
    println("Feel free to type in commands")
    start()
end

end # module Waiij