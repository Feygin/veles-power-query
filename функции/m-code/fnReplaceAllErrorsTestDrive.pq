let
    source = Excel.CurrentWorkbook(){[Name="fnReplaceErrorsSource"]}[Content],
    test = 
        fnReplaceAllErrors(
            source
        )
in
    test