let
    data = fnGetTableFromFile(dimension_path, [kind = "Sheet", name = "техника"]),
    promote_header = Table.PromoteHeaders(data, [PromoteAllScalars = true]),
    remove_empty_rows = Table.SelectRows(promote_header, each ([наименование техники] <> null)),
    select_cols = Table.SelectColumns(remove_empty_rows, {"наименование техники", "группа техники", "подгруппа техники"}),
    duplicate_key_col = Table.DuplicateColumn(select_cols, "наименование техники", "наименование техники_key"),
    clean_key_col = fnCleanData(duplicate_key_col, [columns =  {"наименование техники_key"}]),
    check_pk = fnCheckPrimaryKey(clean_key_col, [column = "наименование техники_key", file_name = "справочник google", table_name = "техника"]),
    add_sort = fnAddSort(check_pk, [columns = {"наименование техники", "группа техники"}]),
    add_refresh_datetime = fnAddRefreshDateTime(add_sort, [column = "время обновления google"])
in
    add_refresh_datetime