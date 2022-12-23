/* 
    загружаем таблицу с переименованием проекта, подпроекта, организации
 */
let
    source = Excel.CurrentWorkbook(){[Name="нормализация"]}[Content], //загружаем таблицу
    change_dtype = Table.TransformColumnTypes( //изменяем тип данных на текстовый
        source,
        {
            {"имя столбца", type text}, 
            {"значение исходное", type text}, 
            {"значение результат", type text}
        }
    ), 
    filter_nulls = Table.SelectRows( //исключаем строки без значений
        change_dtype, 
        each ([имя столбца] <> null) and ([значение исходное] <> null) and ([значение результат] <> null)
    ), 
    norm_data = Table.TransformColumns( //нормализуем переименование столбцов
        filter_nulls,
        {
            {"значение исходное", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"значение результат", each Text.Trim(Text.Clean(Text.Lower(_))), type text}
        }
    ),
    distinct = Table.Distinct(norm_data, {"имя столбца", "значение исходное"}) //удаляем дубликаты
in
    distinct