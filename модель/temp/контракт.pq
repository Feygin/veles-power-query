let
    filter_data = 
        Table.SelectRows(
            #"content", 
            each List.Contains({"_контракт_joined"}, [Item], Comparer.OrdinalIgnoreCase)
        ),
    combine_tables = Table.Combine(filter_data[Data]),
    change_dtype = fnTransformColType(combine_tables, [columns = #"схема условия"[тип данных][контракт]]),
    select_columns = Table.SelectColumns(change_dtype, #"схема условия"[поле][контракт], MissingField.UseNull)

in
    select_columns