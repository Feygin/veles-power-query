/* 
    объединяем таблицы факт из баз вм
 */
let
    source = #"_содержимое_факт", //ссылка шаг в котором извлечено содержимое баз факта
    filter_data = Table.SelectRows(source,  each [Item] = "факт"), //оставляем таблицы c фактом
    combine_tables = Table.Combine(filter_data[Data]), //объединяем таблицы
    select_columns = Table.SelectColumns( //выбираем требуемые поля
        combine_tables,
       {
            "дата",
            "проект_key",
            "организация_key",
            "типовые_key",
            "типовые вед поз",
            "объем факт",
            "нормочасы факт",
            "нормочасы зимний факт",
            "часы факт"
        }
    ),
    rename_columns = Table.RenameColumns( //переименовываем часть столбцов, чтобы они соответствовали единому наименованию
        select_columns,
        {
            {"объем факт", "объем"},
            {"нормочасы факт", "нормочасы"},
            {"нормочасы зимний факт", "нормочасы зимний"},
            {"часы факт", "часы"}
        }
    ),
    change_dtype = Table.TransformColumnTypes( //изменяем тип данных
        rename_columns,
        {
            {"дата", type date},
            {"проект_key", type text},
            {"организация_key", type text},
            {"типовые_key", type text},
            {"типовые вед поз", type text},
            {"объем", type number},
            {"нормочасы", type number},
            {"нормочасы зимний", type number},
            {"часы", type number}
        }
    )
in
    change_dtype