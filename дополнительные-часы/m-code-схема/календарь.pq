/* 
    из файла схема загружаем таблицу "календарь"
 */
let
    source = fnGetTableFromFile(#"схема_путь", [kind = "Table", name = "календарь"]), //загружаем таблицу календарь
    select_cols = Table.SelectColumns(source, {"дата", "год", "месяц год"}), //выюираем нужные поля
    change_dtype = Table.TransformColumnTypes(select_cols,{{"дата", type date}}) //изменяем тип данных в поле [дата] на date
in
    change_dtype