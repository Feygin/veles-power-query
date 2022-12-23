/* 
    загружаем таблицу с путем к справочнику в google sheets
 */
let
    source = Excel.CurrentWorkbook(){[Name="путь"]}[Content],
    change_dtype = Table.TransformColumnTypes(source,{{"файл", type text}, {"путь", type text}})
in
    change_dtype