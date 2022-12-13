let
    filter_data = 
        Table.SelectRows(
            #"content", 
            each List.Contains({"меры_названия"}, [Item], Comparer.OrdinalIgnoreCase)
        ),
    combine_tables = Table.Combine(filter_data[Data]),
    change_dtype = fnTransformColType(combine_tables, [columns = #"схема условия"[тип данных][меры_названия]]),
    add_sort = fnAddSort(change_dtype, [columns = #"схема условия"[модель сортировка][меры_названия]]),
    select_columns = Table.SelectColumns(add_sort, #"схема условия"[поле][меры_названия])
in
    select_columns