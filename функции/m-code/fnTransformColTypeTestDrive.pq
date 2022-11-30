let
    source = Excel.CurrentWorkbook(){[Name="fnTransformColTypeSource"]}[Content],
    test_no_missing_cols = 
        fnTransformColType(
            source,
            [
                columns = {"numbers_with_text_numbers", "dates", "numbers_with_invalid_data"},
                columns_type = {"Number.Type", "Date.Type", "Number.Type"},
                transform_subset = false
            ]
        ),
    test_missing_cols_no_subset =
        fnTransformColType(
            source,
            [
                columns = {"numbers_with_text_numbers", "missing_col"},
                columns_type = {"Number.Type", "Date.Type"},
                transform_subset = false
            ]
        ),
    test_missing_cols_with_subset =
        fnTransformColType(
            source,
            [
                columns = {"numbers_with_text_numbers", "missing_col"},
                columns_type = {"Number.Type", "Date.Type"},
                transform_subset = true
            ]
        )
in
    test_missing_cols_with_subset