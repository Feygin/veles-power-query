let
    left = Excel.CurrentWorkbook(){[Name="fnJoinSourceLeft"]}[Content],
    right = Excel.CurrentWorkbook(){[Name="fnJoinSourceRight"]}[Content],
    right_different_id = Table.RenameColumns(right, {{"id", "key"}}),

    test_default_params = fnJoinTable(
        [
            left_table = left,
            left_table_key = "id",
            right_table = right,
            join_columns = {"descr", "descr1"}
        ]
    ),
    test_custom_params = fnJoinTable(
        [
            left_table = left,
            left_table_key = "id",
            right_table = right_different_id,
            right_table_key = "key",
            join_columns = {"descr", "descr1"},
            join_columns_new_names = {"changed_descr_1", "changed_descr_2"},
            join_kind = JoinKind.Inner
        ]
    )
in
    test_custom_params