let
    source = #"_transformation",
    filter_successfull = Table.SelectRows(source, each [статус извлечения] = "Извлечено"),
    check_any_data = if Table.IsEmpty(filter_successfull) then error Error.Record("Ни один из файлов не был успешно трансформирован") else filter_successfull,
    select_cols = Table.SelectColumns(check_any_data, {"имя файла", "SelectContract"}),
    combine = Table.Combine(select_cols[SelectContract]),
    reorder_cols = Table.ReorderColumns(combine, #"столбцы_контракт", MissingField.Ignore)
in
    reorder_cols
