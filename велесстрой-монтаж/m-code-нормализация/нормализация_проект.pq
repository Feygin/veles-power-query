/* 
    получаем список проектов для переименования
 */
let
    source = #"нормализация", //ссылка на предыдущий шаг
    filter_data = Table.SelectRows(source, each ([имя столбца] = "проект")),
    select_mapping = Table.SelectColumns(filter_data,{"значение исходное", "значение результат"}),
    to_rows = Table.ToRows(select_mapping),
    buffer = List.Buffer(to_rows) //в буфер для ускорения времени работы
in
    buffer