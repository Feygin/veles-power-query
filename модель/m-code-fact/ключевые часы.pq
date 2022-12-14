/* 
    объединяем таблицы ключевых часов часов из баз ключевых
 */
let
    source = #"_содержимое_ключевые", //ссылка на шаг в котором извлечено содержимое баз ключевых часов
    filter_data = Table.SelectRows(source,  each [Item] = "ключевые_часы"), //оставляем таблицы c ключевыми часами
    combine_tables = Table.Combine(filter_data[Data]), //объединяем таблицы
    select_columns = Table.SelectColumns( //выбираем требуемые поля
        combine_tables,
       {
            "дата",
            "проект_key",
            "организация_key",
            "ключевые_key",
            "типовые_key",
            "люди",
            "часы"
        }
    ),
    change_dtype = Table.TransformColumnTypes( //изменяем тип данных
        select_columns,
        {
            {"дата", type date},
            {"проект_key", type text},
            {"организация_key", type text},
            {"ключевые_key", type text},
            {"типовые_key", type text},
            {"люди", type number},
            {"часы", type number}
        }
    )
in
    change_dtype