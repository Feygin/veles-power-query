/* 
    загружаем таблицу с параметрами
    таблица хранится на листе параметры
 */
let
    source = Excel.CurrentWorkbook(){[Name="параметр"]}[Content]
in
    source