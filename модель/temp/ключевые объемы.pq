let
    filter_data = 
        Table.SelectRows(
            #"content", 
            each List.Contains({"_ключевые_объемы_joined"}, [Item], Comparer.OrdinalIgnoreCase)
        ),
    combine_tables = Table.Combine(filter_data[Data]),
    change_dtype = fnTransformColType(combine_tables, [columns = #"схема условия"[тип данных][ключевые_объемы]]),
    select_columns = Table.SelectColumns(change_dtype, #"схема условия"[поле][ключевые_объемы], MissingField.UseNull)
in
    select_columns