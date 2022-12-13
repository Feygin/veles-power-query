/* 
    из файла схема загружаем таблицу "календарь"
 */
let
    source = #"_содержимое_схема", //ссылка на предыдущий шаг, с содержимом файла схема

    filter_data = Table.SelectRows(source,  each [Item] = "календарь"), //оставляем таблицу календарь
    combine_tables = Table.Combine(filter_data[Data]), //объединяем таблицы

    select_cols = Table.SelectColumns(source, {"дата", "год", "месяц год"}), //выюираем нужные поля
    change_dtype = Table.TransformColumnTypes(select_cols,{{"дата", type date}}) //изменяем тип данных в поле [дата] на date
in
    change_dtype