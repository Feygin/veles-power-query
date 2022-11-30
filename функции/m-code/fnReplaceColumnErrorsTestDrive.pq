let
    source = Excel.CurrentWorkbook(){[Name="fnReplaceErrorsSource"]}[Content],
    test = 
        fnReplaceColumnErrors(
            source,
            [
                columns = {"col1", "col2"}
            ]
        )
in
    test