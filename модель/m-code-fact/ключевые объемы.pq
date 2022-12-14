/* 
    объединяем таблицы ключевых объемов из баз ключевых
 */
let
    source = #"_содержимое_ключевые", //ссылка на шаг в котором извлечено содержимое баз ключевых объемов
    filter_data = Table.SelectRows(source,  each [Item] = "ключевые_объемы"), //оставляем таблицы c ключевыми объемами
    combine_tables = Table.Combine(filter_data[Data]), //объединяем таблицы
    select_columns = Table.SelectColumns( //выбираем требуемые поля
        combine_tables,
       {
            "дата",
            "проект_key",
            "организация_key",
            "ключевые_key",
            "типовые_key",
            "объем"
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
            {"объем", type number}
        }
    )
in
    change_dtype