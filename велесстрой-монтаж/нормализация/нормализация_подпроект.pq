let
    source = нормализация,
    filter_data = Table.SelectRows(source, each ([имя столбца] = "подпроект")),
    select_mapping = Table.SelectColumns(filter_data,{"значение исходное", "значение результат"}),
    to_rows = Table.ToRows(select_mapping)
in
    to_rows