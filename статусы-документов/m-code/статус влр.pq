let
    source = #"схема таблицы"[доп_часы],
    select_columns = 
        Table.SelectColumns(
            source,
            {
                "дата",
                "проект 1с",
                "организация 1с",
                "журнал тип",
                "ведомость имя",
                "договор",
                "ответственный цок",
                "требование",
                "дата актуализации",
                "передан на проверку",
                "выданы замечания",
                "согласован оп",
                "подписан оп",
                "согласован цок",
                "статус",
                "ответственный оп",
                "ответственный за формирование",
                "руководитель оп",
                "куратор оп",
                "примечание"
            }
        ),
    transform_types = 
        Table.TransformColumnTypes(
            select_columns,
            {
                {"дата", Date.Type},
                {"дата актуализации", Date.Type},
                {"передан на проверку", Date.Type},
                {"выданы замечания", Date.Type},
                {"согласован оп", Date.Type},
                {"подписан оп", Date.Type},
                {"согласован цок", Date.Type}
            }
        ),
    filter_required = 
        Table.SelectRows(
            transform_types,
            each [требование] = "требуется"
        ),
    replace_missing_contracts = Table.TransformColumns(filter_required, {"договор", each if _ = null then "#не определен" else _})
in
    replace_missing_contracts