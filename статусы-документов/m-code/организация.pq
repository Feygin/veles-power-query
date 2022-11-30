let
    source = #"схема таблицы"[организация],
    select_columns = 
        Table.SelectColumns(
            source,
            {
                "организация 1с"
            }
        ),
    add_norm_key = 
        let
            dup_key = Table.DuplicateColumn(select_columns, "организация 1с", "организация 1с нормализованный"),
            norm_key = Table.TransformColumns(dup_key, {"организация 1с нормализованный", each Text.Trim(Text.Lower(Text.Clean(_))), type text})
        in
            norm_key,
    distinct_vals = Table.Distinct(add_norm_key, "организация 1с нормализованный"),
    remove_norm_key = Table.RemoveColumns(distinct_vals, "организация 1с нормализованный")
in
    remove_norm_key