
-- ==== Global Form platoons ==== --

PlatoonTemplate {
    Name = 'U123 Amphibious 1 10',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.AMPHIBIOUS - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 1, 10, 'Attack', 'none' }
    }
}
