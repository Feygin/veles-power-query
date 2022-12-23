/* 
    загружаем таблицу с зимним коэффициентом
 */
let
    source = Excel.CurrentWorkbook(){[Name="зимний_коэф"]}[Content], //загружаем таблицу
    change_dtype = Table.TransformColumnTypes(source,{{"дата", type date}, {"зимний коэф", type number}}), //изменяем тип данных
    replace_errors = fnReplaceAllErrors(change_dtype), //заменяем ошибки в таблице
    filter_nulls = Table.SelectRows(replace_errors, each ([дата] <> null) and ([дата] <> "")), //удаляем строки без дат
    check_key_unique = //проверяем уникальность ключа
		let
			row_count = Table.RowCount(filter_nulls), //кол-во строк
			row_dcount = 
                Table.RowCount( //кол-во строк по уникальным позициям ключа
                    Table.Distinct(filter_nulls, {"дата"})
                ),
			is_unique = 
                if row_count = row_dcount then 
                    filter_nulls 
                else 
                    error Error.Record(
                                "Таблица с зимним коэффициентом содиржит дубликаты строк.",
                                "Необходимо удалить дубликаты строк по ключу <дата>"
                            )
		in
			is_unique
in
    check_key_unique