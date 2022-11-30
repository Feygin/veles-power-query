let
    fact_agg = //группируем факт по ключу и аггрегируем объемы и часы
        Table.Group(
            #"_факт_источник", 
            {"имя файла", "индекс"}, 
            {
                {"объем факт", each List.Sum([объем факт]), type number},
                {"часы факт", each List.Sum([часы факт]), type number}
            }
        ),
    contract_data = //выбираем в таблице контракт накопители
        Table.SelectColumns(
            #"_контракт_источник",
            {
                "имя файла", 
                "индекс",
                "объем накопительно",
                "часы накопительно"
            }
        ),
    //соединяем накопительную и суммарную месячную часть
    join_contract_with_fact = Table.NestedJoin(contract_data, {"имя файла", "индекс"}, fact_agg, {"имя файла", "индекс"}, "_joined", JoinKind.LeftOuter),
    expand_data = Table.ExpandTableColumn(join_contract_with_fact, "_joined", {"объем факт", "часы факт"}),
    replace_nulls = //заменяем null на 0 для исключения ошибок при арифметике
        Table.ReplaceValue(
            expand_data,
            null,0,Replacer.ReplaceValue,
            {"объем накопительно", "объем факт", "часы накопительно", "часы факт"}
        ),
    add_delta_volume_abs = //рассчитываем дельты
        Table.AddColumn(
            replace_nulls, 
            "объем дельта (накопительно - факт)", 
            each Number.Round([#"объем накопительно"] - [#"объем факт"], 2), //абсолютная
            Number.Type
        ),
    add_delta_volume_pct = 
        Table.AddColumn(
            add_delta_volume_abs, 
            "объем дельта (накопительно % факт)",
            each 
                if ([#"объем накопительно"] <> 0) and ([объем факт] <> 0) then //для случая если оба объема ненулевые
                    Number.Round([#"объем дельта (накопительно - факт)"] / [#"объем факт"], 2) //стандартная арифметика
                else if ([#"объем накопительно"] = 0) and ([объем факт] = 0) then //в случае нулевых объемов
                    0
                else if ([#"объем накопительно"] = 0) and ([объем факт] <> 0) then 
                    -Number.Sign([объем факт]) //+-100%
                else if ([#"объем накопительно"] <> 0) and ([объем факт] = 0) then
                    Number.Sign([#"объем накопительно"]) //+-100%
                else
                    null,
                Percentage.Type
        ),
	add_delta_hours_abs = 
        Table.AddColumn(
            add_delta_volume_pct,
            "часы дельта (накопительно - факт)",
            each Number.Round([#"часы накопительно"] - [#"часы факт"], 2),
            Number.Type
        ),
	add_delta_hours_pct = 
        Table.AddColumn(
            add_delta_hours_abs,
            "часы дельта (накопительно % факт)",
            each 
                if ([#"часы накопительно"] <> 0) and ([часы факт] <> 0) then
                    Number.Round([#"часы дельта (накопительно - факт)"] / [#"часы факт"], 2)
                else if ([#"часы накопительно"] = 0) and ([часы факт] = 0) then
                    0
                else if ([#"часы накопительно"] = 0) and ([часы факт] <> 0) then
                    -Number.Sign([часы факт])
                else if ([#"часы накопительно"] <> 0) and ([часы факт] = 0) then
                    Number.Sign([#"часы накопительно"])
                else 
                    null,
                Percentage.Type
        )
in
    add_delta_hours_pct