let
    source = #"схема таблицы"[вкс],
    select_columns = 
        Table.SelectColumns(
            source,
            {
                "дата",
                "проект 1с",
                "объект",
                "договор",
                "организация 1с",
                "признак",
                "ответственный оп",
                "требование",
                "дата актуализации",
                "передан на проверку",
                "выданы замечания",
                "согласован",
                "подписан",
                "статус"
            }
        ),
    transform_types = 
        Table.TransformColumnTypes(
            select_columns,
            {
                {"дата", Date.Type},
                {"дата актуализации", Date.Type},
                {"передан на проверку", Date.Type},
                {"согласован", Date.Type},
                {"подписан", Date.Type}
            }
        ),
    filter_required = 
        Table.SelectRows(
            transform_types,
            each [требование] = "требуется"
        )
in
    filter_required