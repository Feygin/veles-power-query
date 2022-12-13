/* 
    получаем список взаимного расположения столбцов в таблице факт
    расположение задается пользователем на листе настройка столбцов 
 */
let
    source = Excel.CurrentWorkbook(){[Name="столбцы_факт"]}[Content], //таблица с взаимным расположением фактических столбцов столбцов
    change_dtype = Table.TransformColumnTypes(source,{{"расположение столбцов факт", type text}}),//изменяем тип данных на текст
    filter_nulls = Table.SelectRows(change_dtype, each ([расположение столбцов факт] <> null) and ([расположение столбцов факт] <> "")), //удаляем пустые строки
    clean_text = Table.TransformColumns(filter_nulls,{{"расположение столбцов факт", each Text.Trim(Text.Clean(Text.Lower(_))), type text}}), //нормализуем текст
    remove_dups = Table.Distinct(clean_text), //удаляем дубликаты
    to_list = remove_dups[расположение столбцов факт] //преобразовываем таблицу в список
in
    to_list