/* 
    загружаем таблицу с путями к источникам
    таблица хранится на одном из листов книги
 */
let
    source = Excel.CurrentWorkbook(){[Name="путь"]}[Content], //получаем данные таблицы
    change_dtype = Table.TransformColumnTypes(source,{{"файл", type text}, {"путь", type text}}) //преобразовываем тип данных столбцов в текст
in
    change_dtype