/* 
    объединяем таблицы 1к1н (карнет) из баз доп часов
 */
let
    source = #"_содержимое_дополнительные_часы", //ссылка шаг в котором извлечено содержимое баз дополнительных часов
    filter_data = Table.SelectRows(source,  each [Item] = "_1к1н"), //оставляем таблицы c карнетом
    combine_tables = Table.Combine(filter_data[Data]), //объединяем таблицы
    select_columns = Table.SelectColumns( //выбираем требуемые поля
        combine_tables,
       {
            "дата",
            "проект_key",
            "организация_key", 
            "1н.часы",
            "1к.часы"
        }
    ),
    change_dtype = Table.TransformColumnTypes( //изменяем тип данных
        select_columns,
        {
            {"дата", type date},
            {"проект_key", type text},
            {"организация_key", type text},
            {"1н.часы", type number},
            {"1к.часы", type number}
        }
    )
in
    change_dtype