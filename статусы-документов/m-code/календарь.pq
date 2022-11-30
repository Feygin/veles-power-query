let
    source = #"схема таблицы"[календарь],
    select_columns = 
        Table.SelectColumns(
            source,
            {
                "дата",
                "год_номер",
                "год", 
                "месяц_номер",
                "месяц",
                "месяц год_номер",
                "месяц год",
                "декада",
                "декада_номер",
                "декада месяц",
                "декада месяц_номер",
                "декада месяц год",
                "декада месяц год_номер"
            }
        ),
    change_dtype = 
        Table.TransformColumnTypes(
            select_columns,
            {
                {"дата", Date.Type},
                {"год_номер", Int64.Type},
                {"месяц_номер", Int64.Type},
                {"месяц год_номер", Int64.Type},
                {"декада_номер", Int64.Type},
                {"декада месяц_номер", Int64.Type},
                {"декада месяц год_номер", Int64.Type}
            }
        ),
    add_et1_key = Table.DuplicateColumn(change_dtype, "декада месяц год", "декада месяц год_key"),
    norm_key = Table.TransformColumns(add_et1_key, {"декада месяц год_key", each Text.Trim(Text.Clean(Text.Lower(_)))})
in
    norm_key