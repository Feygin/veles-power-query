/* 
    загружаем таблицу с нормализацией для поля организация
 */
let
    source = Table.Buffer(Excel.CurrentWorkbook(){[Name="нормализация"]}[Content]), //извлекаем таблицу с нормализацией из текущего файла
    normalize = Table.TransformColumns( //нормализуем текстовые поля
        source,{
            {"поле", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"значение отчет ключевых", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"значение схема", each Text.Trim(Text.Clean(Text.Lower(_))), type text}
        }
    ),
    filter_subcontractor = Table.SelectRows(normalize, each [поле] = "организация"), //фильтруем по организации организации
    remove_cols = Table.RemoveColumns(filter_subcontractor,{"поле"}), //удаляем столбец поле
    remove_nulls = Table.SelectRows( //исключаем строки с пустотами
        remove_cols, 
        each [значение отчет ключевых] <> null 
            and [значение отчет ключевых] <> ""
            and [значение схема] <> null
            and [значение схема] <> ""
    ),
    distinct = Table.Distinct(remove_nulls, "значение отчет ключевых"), //убираем дубликаты в вводных данных
    to_list = Table.ToRows(remove_cols) //трансформируем таблицу в список из списков с парой значений "что ищем", "на что заменяем"
in
    to_list