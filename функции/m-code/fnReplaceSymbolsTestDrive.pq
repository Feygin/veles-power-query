let
    source = Excel.CurrentWorkbook(){[Name="fnReplaceSymbolsSource"]}[Content],
    test_replace_dots_in_numbers = 
        fnReplaceSymbols(
            source,
            [
                columns = {"numbersWithDotsAndCommas", "anotherNumbersWithDotsAndCommas"}
            ]
        ),
    test_replace_other_symbols = 
        fnReplaceSymbols(
            source,
            [
                columns = {"textWithDifferentSymbols"},
                replacement = {{"_", ""}, {"@", "a"}, {"!", "t"}}
            ]
        )
in
    test_replace_other_symbols