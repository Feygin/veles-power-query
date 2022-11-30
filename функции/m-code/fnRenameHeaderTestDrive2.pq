let
    source = Excel.CurrentWorkbook(){[Name="fnRenameHeaderSource"]}[Content],
    renames_valid = 
        let
            data = Excel.CurrentWorkbook(){[Name="fnRenameHeaderFindReplaceValid"]}[Content],
            to_rows = Table.ToRows(data)
        in
            to_rows,
    
    renames_invalid = 
        let
            data = Excel.CurrentWorkbook(){[Name="fnRenameHeaderFindReplaceInValid"]}[Content],
            to_rows = Table.ToRows(data)
        in
            to_rows,
    test_valid = 
        fnRenameHeader2(
            source,
            [
                renames = renames_valid
            ]
        ),
    test_valid_without_prenorm = 
        fnRenameHeader2(
            source,
            [
                renames = renames_valid,
                prenormalize_header = false
            ]
        ),
    test_valid_custom_names = 
        fnRenameHeader2(
            source,
            [
                renames = renames_valid,
                find_column_name = "find",
                replace_column_name = "replace"
            ]
        ),
    test_invalid = 
        fnRenameHeader2(
            source,
            [
                renames = renames_invalid
            ]
        ),
    test_invalid_custom_err = 
        fnRenameHeader2(
            source,
            [
                renames = renames_invalid,
                table_name = "TEST_TABLE",
                file_name = "TEST_FILE"
            ]
        )
in
    test_invalid_custom_err