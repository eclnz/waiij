# Test Suite

Tests use [TestItems.jl](https://github.com/julia-testing/TestItems.jl) and are discovered automatically by the VS Code Julia extension.

## Running in VS Code

Open the Test Explorer (beaker icon in the sidebar) to run or debug individual test items. Right-click any test to run or debug it — the debugger will stop on breakpoints inside `src/`.

## Running from the command line

```
julia --project=. -e 'using TestItemRunner; @run_package_tests'
```

## Running via the REPL

```julia
] activate .
using TestItemRunner
@run_package_tests
```
