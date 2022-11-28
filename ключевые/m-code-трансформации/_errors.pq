let
    source = #"_transformation",
    select_cols = Table.SelectColumns(source, {"имя файла", "лист", "Unpivot"}),
    keep_rows_with_erros = Table.SelectRowsWithErrors(select_cols),
    add_status = Table.AddColumn(keep_rows_with_erros, "статус", each "ошибки при извлечении"),
    remove_trasformed_col = Table.RemoveColumns(add_status,{"Unpivot"})
in
    remove_trasformed_col