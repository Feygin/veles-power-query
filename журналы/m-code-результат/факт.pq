let
    source = #"_трансформируем_данные",
    filter_successfull = Table.SelectRows(source, each [статус извлечения] = "Извлечено"),
    check_any_data = if Table.IsEmpty(filter_successfull) then error Error.Record("Ни один из файлов не был успешно трансформирован") else filter_successfull,
    select_cols = Table.SelectColumns(check_any_data, {"имя файла", "FactUnpivot"}),
    combine = Table.Combine(select_cols[FactUnpivot]),
    reorder_cols = Table.ReorderColumns(combine, #"столбцы_факт", MissingField.Ignore)
in
    reorder_cols