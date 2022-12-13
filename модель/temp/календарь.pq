let
    filter_data = 
        Table.SelectRows(
            #"content", 
            each List.Contains({"календарь"}, [Item], Comparer.OrdinalIgnoreCase)
        ),
    combine_tables = Table.Combine(filter_data[Data]),
    change_dtype = fnTransformColType(combine_tables, [columns = #"схема условия"[тип данных][календарь]])
in
    change_dtype