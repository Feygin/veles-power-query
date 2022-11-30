let
    data = fnGetTableFromFile(dimension_path, [kind = "Sheet", name = "проект"]),
    promote_header = Table.PromoteHeaders(data, [PromoteAllScalars = true]),
    select_cols = Table.SelectColumns(promote_header, {"проект", "проект краткий", "подпроект"}),
    change_dtype = Table.TransformColumnTypes(select_cols,{{"проект", type text}, {"проект краткий", type text}, {"подпроект", type text}}),
    filldown_project = Table.FillDown(change_dtype, {"проект", "проект краткий"}),
    filter_nulls = Table.SelectRows(filldown_project, each [подпроект] <> null and [подпроект] <> ""),
    duplicate_project_key = Table.DuplicateColumn(filter_nulls, "проект", "проект_dup"),
    duplicate_subproject_key = Table.DuplicateColumn(duplicate_project_key, "подпроект", "подпроект_dup"),
    clean_keys = fnCleanData(duplicate_subproject_key, [columns =  {"проект_dup", "подпроект_dup"}]),
    combine_key = Table.CombineColumns(clean_keys,{"проект_dup", "подпроект_dup"},Combiner.CombineTextByDelimiter("_", QuoteStyle.None),"проект_key"),
    check_pk = fnCheckPrimaryKey(combine_key, [column = "проект_key", file_name = "справочник google", table_name = "проект_2_0"]),
    add_sort = fnAddSort(check_pk, [columns = {"проект", "подпроект"}]),
    add_refresh_datetime = fnAddRefreshDateTime(add_sort, [column = "время обновления google"])
in
    add_refresh_datetime