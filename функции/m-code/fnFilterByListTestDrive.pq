let
    source = Excel.CurrentWorkbook(){[Name="fnFilterByListSource"]}[Content],
    filter = {"val1", "VAL2"},

    test_default = 
        fnFilterByList(
            source,
            [
                column = "col2",
                filter = filter
            ]
        ),
    test_change_comparer = 
        fnFilterByList(
            source,
            [
                column = "col2",
                filter = filter,
                comparer = Comparer.Ordinal
            ]
        )
in
    test_change_comparer