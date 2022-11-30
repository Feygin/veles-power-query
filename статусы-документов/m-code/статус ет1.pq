let
    source = #"схема таблицы"[ет1],
    add_date_key = Table.DuplicateColumn(source, "декада месяц год", "декада месяц год_key"),
    norm_key = Table.TransformColumns(add_date_key, {"декада месяц год_key", each Text.Trim(Text.Clean(Text.Lower(_)))}),
    join_date = 
        let
            calendar_decade_granularity = Table.Distinct(#"календарь", {"декада месяц год_key"}),
            join_date = 
                Table.NestedJoin(
                    norm_key, "декада месяц год_key",
                    calendar_decade_granularity, "декада месяц год_key",
                    "календарь_joined",JoinKind.LeftOuter
                )
        in
            join_date,
    expand_date = 
        Table.ExpandTableColumn(
            join_date, "календарь_joined", {"дата"}
        ),
    select_columns = 
        Table.SelectColumns(
            expand_date,
            {
                "дата",
                "проект 1с",
                "организация 1с",
                "журнал имя",
                "журнал дисциплина",
                "договор",
                "требование",
                "журнал дата",
                "дата актуализации",
                "получен",
                "согласован",
                "количество дней согласования",
                "статус",
                "примечание"
            }
        ),
    transform_types = 
        Table.TransformColumnTypes(
            select_columns,
            {
                {"журнал дата", Date.Type},
                {"дата актуализации", Date.Type},
                {"получен", Date.Type},
                {"согласован", Date.Type},
                {"количество дней согласования", Int64.Type}
            }
        ),
    replace_missing_contracts = Table.TransformColumns(transform_types, {"договор", each if _ = null then "#не определен" else _})
in
    replace_missing_contracts