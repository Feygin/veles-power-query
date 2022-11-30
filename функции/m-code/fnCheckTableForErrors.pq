
/* 
    Цель: получение ошибок ячеек содержащихся в столбцах таблицы в формате -
		номер строки, доплнительный контекст из столбцов columns, например, имя файла и и тд,
		имя столбца, ошибка с расшифровкой 
 */
(source as table, _parameter as record)  =>
let
    columns = Record.FieldOrDefault(_parameter, "columns", null), //столбцы таблицы задающие дополнительный контекст

    select_rows_with_errors = Table.SelectRowsWithErrors(source), //строки содержащие ячейки с ошибками
	add_index = Table.AddIndexColumn //добавляем номер строки по порядку
	(
		select_rows_with_errors,
		"номер строки",
		1,
		1
	),
	//столбцы c контекстом для которых будем транспонировать столбцы в строки 
	//номер строки обязателен, так как он гаранитирует уникальность строк для группировки
    context_columns = if columns <> null then columns & {"номер строки"} else {"номер строки"}, 
    fnTransposeGroup = //функция для транспонирования столбцов в строки
        (context_columns)=>
            (group)=>
                let
                    group_column_names = Table.ColumnNames(group), //названия столбцов группы
                    group_column_names_except_context_columns = List.Difference( group_column_names, context_columns), //названия столбцов группы за исключением контекстных строк по которым осуществляется группировка
                    remove_context_columns = Table.RemoveColumns(group, context_columns), //удаляем контекстные столбцы
                    group_values = Table.ToRows(remove_context_columns), //представляем строки в виде списка значений, так как группируем по уникальному индексу, результат всегда единственная строка
                    row_value = group_values{0}, //получаем значения строки
                    construct_table = Table.FromColumns //транспонируем таблицу путем переориентировки строк в столбцы
                    (
                        {group_column_names_except_context_columns, row_value},
                        {"имя столбца", "значение с ошибкой"}
                    )
                in
                    construct_table,
	get_row_values = Table.Group //транспонируем столбцы для контекста
	(
		add_index,
		context_columns,
		{{"транспонированные столбцы", fnTransposeGroup(context_columns)}}
	),
	expand_row_values = Table.ExpandTableColumn //раскрываем значения столбцов в строки
	(
		get_row_values,
		"транспонированные столбцы",
		{"имя столбца", "значение с ошибкой"}
	),
	check_error = Table.AddColumn //проверяем наличие ошибок 
	(
		expand_row_values,
		"проверка ошибки",
		each try [значение с ошибкой]
	),
	get_err_description = Table.ExpandRecordColumn //извлекаем запись с ошибками
	(
		check_error,
		"проверка ошибки",
		{"HasError", "Value", "Error"},
		{"содержит ошибку", "значение", "ошибка"}
	),
	filter_errors = Table.SelectRows //фильтруем таблицу по строкам содержащим ошибки
	(
		get_err_description,
		each 
		(
			[содержит ошибку] = true
		)
	),
	expand_error = Table.ExpandRecordColumn //извлекаем детали ошибки
	(
		filter_errors,
		"ошибка",
		{"Reason", "Message", "Detail"},
		{"причина ошибки", "сообщение ошибки", "детали"}
	),
	fnExpandDetails = (source)=>
		if Value.Is(source, type record) then
            Text.Combine({"Name: ", source[Name], ", Value: ", source[Value]})
        else source,
	expand_details = Table.TransformColumns(
		expand_error,
		{"детали", fnExpandDetails, type text}
	)
 in 
	expand_details