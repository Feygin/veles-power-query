let
    source = #"схема таблицы"[договор],
    select_columns = 
        Table.SelectColumns(
            source,
            {
                "проект 1с",
                "объект",
                "договор",
                "организация"
            }
        ),
    add_norm_key = 
        let
            dup_key = Table.DuplicateColumn(select_columns, "договор", "договор нормализованный"),
            norm_key = Table.TransformColumns(dup_key, {"договор нормализованный", each Text.Trim(Text.Lower(Text.Clean(_))), type text})
        in
            norm_key,
    distinct_vals = Table.Distinct(add_norm_key, "договор нормализованный"),
    remove_norm_key = Table.RemoveColumns(distinct_vals, "договор нормализованный"),
    distinct = Table.Distinct(remove_norm_key, {"договор"}),
    add_system_row =
        let
            system_row = 
                #table(
                    {
                        "проект 1с",
                        "объект",
                        "договор",
                        "организация"
                    },
                    {
                        {
                            "#не определен", 
                            "#не определен", 
                            "#не определен", 
                            "#не определен"
                        }
                    }
                ),
            add_system_row = Table.Combine({distinct, system_row})
        in
            add_system_row
in
    add_system_row