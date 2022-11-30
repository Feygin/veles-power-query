/* 
	Функция для проверки уникальности значений или наличия null в столбце.
 */
(
    source as table, _parameter as record
)=> 
 let
    // [
    column = Record.Field(_parameter, "column"),
    table_name = Record.FieldOrDefault(_parameter, "table_name", "#таблица не указана"), //для ошибки
    file_name = Record.FieldOrDefault(_parameter, "file_name", "#файл не указан"), //для ошибки

	column_buffer = List.Buffer(Table.Column(source, column)), //получаем значения из необходимого столбца в виде списка
	is_unique = List.IsDistinct(column_buffer), //проверяем столбец на отсутствие дубликатов
	does_not_contain_null = not List.Contains(column_buffer, null), //проверяем столбец на отсутствие пустых значений

    err = 
    [
        list_to_table = Table.FromColumns({column_buffer}, {column}), //преобразовываем list в table для осуществления группировки
        group_table = //группируем таблицу по ключу для получения дубликтов ключа
            Table.Group(
                list_to_table, column, 
                {{"RowCount", Table.RowCount, type number}}
            ),
        filter_dup = Table.SelectRows(group_table, each Record.Field(_, "RowCount") > 1), //получаем таблицу с дублирующимися ключами
        get_dup_list = Table.Column(filter_dup, column), //получаем список дублирующихся ключей
        join_dup = Text.Combine(get_dup_list, "; "), //формируем текст с разделителем из списка дублирующихся ключей
        err_text = //текст с ошибками
            Text.Format(
                "Файл: ""#{0}"", таблица: ""#{1}"" участвующая в формировании базы"
                & " содержит дубликаты или пустые значения в столбце ""#{2}"". Список дубликатов: ""#{3}""",
                {file_name, table_name, column, join_dup}
            ),
        raise_err = error Error.Record( err_text )
    ],

    result = 
        if is_unique and does_not_contain_null then
                source
        else 
            err[raise_err]
    // ]
 in	
    result
	
