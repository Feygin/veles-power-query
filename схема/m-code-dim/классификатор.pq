let
    data = fnGetTableFromFile(dimension_path, [kind = "Sheet", name = "классификатор"]),
    promote_header = Table.PromoteHeaders(data, [PromoteAllScalars = true]),
    filter_nulls = Table.SelectRows(promote_header, each ([классификатор] <> null)),
    select_cols = Table.SelectColumns(filter_nulls, {"классификатор", "классификатор описание"}),
    change_dtype = Table.TransformColumnTypes(select_cols,{{"классификатор", type text}, {"классификатор описание", type text}}),
    duplicate_classificator_key = Table.DuplicateColumn(change_dtype, "классификатор", "классификатор_key"),
    clean_keys = fnCleanData(duplicate_classificator_key, [columns =  {"классификатор_key"}]),
    check_pk = fnCheckPrimaryKey(clean_keys, [column = "классификатор_key", file_name = "справочник google", table_name = "классификатор_2_0"]),
    add_classificator_with_escr = Table.AddColumn(check_pk, "классификатор с описанием", each [классификатор] & " - " & [классификатор описание], type text),
    add_sort = fnAddSort(add_classificator_with_escr, [columns = {"классификатор"}]),
    add_refresh_datetime = fnAddRefreshDateTime(add_sort, [column = "время обновления google"])
in
    add_refresh_datetime