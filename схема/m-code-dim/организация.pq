let
    data = fnGetTableFromFile(dimension_path, [kind = "Sheet", name = "организация"]),
    promote_header = Table.PromoteHeaders(data, [PromoteAllScalars = true]),
    remove_empty_rows = Table.SelectRows(promote_header, each ([организация] <> null)),
    select_cols = Table.SelectColumns(remove_empty_rows, {"организация", "организация без суб вм", "организация с суб вм", "источник", "тип контракта"}),
    duplicate_key_col = Table.DuplicateColumn(select_cols, "организация", "организация_key"),
    clean_key_col = fnCleanData(duplicate_key_col, [columns =  {"организация_key"}]),
    check_pk = fnCheckPrimaryKey(clean_key_col, [column = "организация_key", file_name = "справочник google", table_name = "организация_2_0"]),
    add_sort = fnAddSort(check_pk, [columns = {"организация", "организация без суб вм"}]),
    add_refresh_datetime = fnAddRefreshDateTime(add_sort, [column = "время обновления google"])
in
    add_refresh_datetime