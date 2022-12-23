/* 
    из файла схема загружаем таблицу с "проект"
 */
let
    source = fnGetTableFromFile(схема_путь, [kind = "Table", name = "проект"]), //загружаем таблицу проект
    select_cols = Table.SelectColumns( //выбираем нужные поля
        source, 
        {
            "проект_key",
            "проект",
            "проект краткий",
            "подпроект",
            "проект_sort",
            "подпроект_sort"
        }
    ) 
in
    select_cols