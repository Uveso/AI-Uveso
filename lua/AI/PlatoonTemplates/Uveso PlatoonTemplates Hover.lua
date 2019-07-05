
-- categories.FLOATING does not exist if all units with this category are disabled (mod manager)
if not categories.FLOATING then categories.FLOATING = categories.HOVER end

-- ==== Global Form platoons ==== --

PlatoonTemplate {
    Name = 'U123 Hover 1 10',
    Plan = 'InterceptorAIUveso',
    GlobalSquads = {
        { categories.MOBILE * categories.HOVER * categories.FLOATING - categories.EXPERIMENTAL - categories.ENGINEER - categories.SCOUT - categories.COMMAND - categories.SUBCOMMANDER, 1, 10, 'Attack', 'none' }
    }
}
