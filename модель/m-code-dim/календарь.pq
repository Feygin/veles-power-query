/* 
    из файла схема загружаем таблицу "календарь"
 */
let
    source = #"_содержимое_схемы"{[Item="календарь",Kind="Table"]}[Data], //ссылка на предыдущий шаг, с содержимом файла схема
    select_cols = Table.SelectColumns(
        source, 
        {
            "дата", 
            "год",
            "год_номер",
            "месяц год",
            "месяц год_номер"
        }
    ), //выюираем нужные поля
    change_dtype = Table.TransformColumnTypes(
        select_cols,
        {
            {"дата", type date},
            {"год", type text},
            {"год_номер", type number},
            {"месяц год", type text},
            {"месяц год_номер", type number}
        }
    ) //изменяем тип данных
in
    change_dtype