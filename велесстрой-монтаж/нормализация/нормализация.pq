let
    source = Excel.CurrentWorkbook(){[Name="нормализация"]}[Content],
    change_dtype = Table.TransformColumnTypes(source,{{"имя столбца", type text}, {"значение исходное", type text}, {"значение результат", type text}}),
    filter_nulls = Table.SelectRows(change_dtype, each ([значение исходное] <> null) and ([значение результат] <> null)),
    norm_data = Table.TransformColumns(filter_nulls,{{"значение исходное", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, {"значение результат", each Text.Trim(Text.Clean(Text.Lower(_))), type text}}),
    distinct = Table.Distinct(norm_data, {"имя столбца", "значение исходное"})
in
    distinct