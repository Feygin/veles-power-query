let
    source = Excel.CurrentWorkbook(){[Name="fnRenameHeaderSource"]}[Content],
    renames_valid = Excel.CurrentWorkbook(){[Name="fnRenameHeaderFindReplaceValid"]}[Content],
    renames_valid_user_cols = Excel.CurrentWorkbook(){[Name="fnRenameHeaderFindReplaceValidUserCols"]}[Content],
    renames_invalid = Excel.CurrentWorkbook(){[Name="fnRenameHeaderFindReplaceInValid"]}[Content],
    test_valid = 
        fnRenameHeader(
            source,
            [
                renames = renames_valid
            ]
        ),
    test_valid_without_prenorm = 
        fnRenameHeader(
            source,
            [
                renames = renames_valid,
                prenormalize_header = false
            ]
        ),
    test_valid_custom_names = 
        fnRenameHeader(
            source,
            [
                renames = renames_valid,
                find_column_name = "find",
                replace_column_name = "replace"
            ]
        ),
    test_invalid = 
        fnRenameHeader(
            source,
            [
                renames = renames_invalid
            ]
        ),
    test_invalid_custom_err = 
        fnRenameHeader(
            source,
            [
                renames = renames_invalid,
                table_name = "TEST_TABLE",
                file_name = "TEST_FILE"
            ]
        )
in
    test_invalid_custom_err