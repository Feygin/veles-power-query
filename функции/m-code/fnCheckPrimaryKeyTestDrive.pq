let
    source = Excel.CurrentWorkbook(){[Name="fnCheckPrimaryKeySource"]}[Content],
    test_valid_col_err= 
        fnCheckPrimaryKey(
            source,
            [
                column = "colValid"
            ]
        ),
    test_col_with_nulls_err= 
        fnCheckPrimaryKey(
            source,
            [
                column = "colWithNulls"
            ]
        ),
    test_col_with_dups_err= 
        fnCheckPrimaryKey(
            source,
            [
                column = "colWithDups"
            ]
        ),
    test_col_with_nulls_and_dups_err= 
        fnCheckPrimaryKey(
            source,
            [
                column = "colWithNullsAndDups"
            ]
        ),
    test_custom_names_err= 
        fnCheckPrimaryKey(
            source,
            [
                column = "colWithNullsAndDups",
                table_name = "TEST_TABLE",
                file_name = "TEST_FILE"
            ]
        )
in
    test_custom_names_err