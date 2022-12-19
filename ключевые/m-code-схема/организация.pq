/* 
    из файла схема загружаем таблицу "организация"
 */
let
    source = fnGetTableFromFile(схема_путь, [kind = "Table", name = "организация"]), //загружаем таблицу организация
    select_cols = Table.SelectColumns( //выбираем нужные поля
        source, 
        {
            "организация_key",
            "организация",
            "организация с суб вм",
            "организация_sort"
        }
    ) 
in
    select_cols