/* 
    получаем список взаимного расположения столбцов в таблице контракт
    расположение задается пользователем на листе настройка столбцов 
 */
let
    source = Excel.CurrentWorkbook(){[Name="столбцы_контракт"]}[Content], //таблица с взаимным расположением контрактных столбцов
    change_dtype = Table.TransformColumnTypes(source,{{"расположение столбцов контракт", type text}}), //изменяем тип данных на текст
    filter_nulls = Table.SelectRows(change_dtype, each ([расположение столбцов контракт] <> null) and ([расположение столбцов контракт] <> "")), //удаляем пустые строки
    clean_text = Table.TransformColumns(filter_nulls,{{"расположение столбцов контракт", each Text.Trim(Text.Clean(Text.Lower(_))), type text}}), //нормализуем текст
    remove_dups = Table.Distinct(clean_text), //удаляем дубликаты
    to_list = remove_dups[расположение столбцов контракт] //преобразовываем таблицу в список
in
    to_list