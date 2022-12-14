/* 
    объединяем таблицы дополнительных часов из баз доп часов
 */
let
    source = #"_содержимое_дополнительные_часы", //ссылка шаг в котором извлечено содержимое баз дополнительных часов
    filter_data = Table.SelectRows(source,  each [Item] = "дополнительные_часы"), //оставляем таблицы c дополнительными часами
    combine_tables = Table.Combine(filter_data[Data]), //объединяем таблицы
    select_columns = Table.SelectColumns( //выбираем требуемые поля
        combine_tables,
       {
            "дата",
            "проект_key",
            "организация_key",
            "классификатор_key",
            "типовые_key",
            "часы"
        }
    ),
    change_dtype = Table.TransformColumnTypes( //изменяем тип данных
        select_columns,
        {
            {"дата", type date},
            {"проект_key", type text},
            {"организация_key", type text},
            {"классификатор_key", type text},
            {"типовые_key", type text},
            {"часы", type number}
        }
    )
in
    change_dtype