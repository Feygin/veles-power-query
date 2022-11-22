let
    source = _get_data,
    select_cols = Table.SelectColumns(source, {"имя файла", "таблица"}),
    add_status = Table.AddColumn(select_cols, "статус", each "извлечено")
in
    add_status