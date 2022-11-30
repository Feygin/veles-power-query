let
    source = Excel.CurrentWorkbook(){[Name="fnCleanDataSource"]}[Content],
    test_clean_data = 
        fnCleanData(
            source,
            [
                columns = {"col1", "col2"}
            ]
        )
in
    test_clean_data