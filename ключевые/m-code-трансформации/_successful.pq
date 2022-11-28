let
    source = #"_transformation",
    select_cols = Table.SelectColumns(source, {"имя файла", "лист", "Unpivot"}),
    remove_rows_with_err = Table.RemoveRowsWithErrors(select_cols),
    add_status = Table.AddColumn(remove_rows_with_err, "статус", each "извлечено"),
    remove_transformed_col = Table.RemoveColumns(add_status,{"Unpivot"})
in
    remove_transformed_col