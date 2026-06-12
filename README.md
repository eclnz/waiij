# Waiij

A Julia implementation of the [Monkey programming language](https://monkeylang.org/).

## Running

```julia
julia --project=. -e 'using Waiij; Waiij.main()'
```

## Testing

Tests are written with [TestItems.jl](https://github.com/julia-testing/TestItems.jl) and live alongside the source files.

### VS Code

Open the Test Explorer (beaker icon in the sidebar) to run or debug individual tests. The debugger will stop on breakpoints inside `src/`.

### Command line

```
julia --project=. -e 'using TestItemRunner; @run_package_tests'
```

### REPL

```julia
] activate .
using TestItemRunner
@run_package_tests
```

### Via Pkg

```julia
] test
```
