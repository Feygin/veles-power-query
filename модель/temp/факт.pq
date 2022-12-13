let
    filter_data = 
        Table.SelectRows(
            #"content", 
            each List.Contains({"_факт_joined"}, [Item], Comparer.OrdinalIgnoreCase)
        ),
    extract_model_date =
        Table.AddColumn(
            filter_data, 
            "дата модель",
            each Date.From(Text.BetweenDelimiters([Name], "_", ".xlsx", {0, RelativePosition.FromEnd}, 0)),
            type date
        ),
    select_data_columns = Table.SelectColumns(extract_model_date, {"Data", "дата модель"}),
    expand_table = Table.ExpandTableColumn(select_data_columns, "Data", #"схема условия"[поле][факт]),
    change_dtype = fnTransformColType(expand_table, [columns = #"схема условия"[тип данных][факт]])
in
    change_dtype