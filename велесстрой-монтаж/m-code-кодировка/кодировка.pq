/* 
    загружаем таблицу с кодировкой
 */
let
    source = Excel.CurrentWorkbook(){[Name="кодировка"]}[Content], //извлекаем таблицу кодировка
    select_columns = Table.SelectColumns( //выбираем столбцы
        source,
        {
            "имя файла",
            "журнал номер",
            "индекс",
            "индекс иерархия",
            "ркц ур1",
            "ркц ур2",
            "ркц ур3",
            "ркц ур4",
            "ркц ур5",
            "ркц ур6",
            "ркц ур7",
            "ркц ур8",
            "ркц ур9",
            "ркц ур10",
            "ркц описание",
            "ед изм",
            "норма",
            "объем контракт",
            "объем накопительно",
            "часы накопительно",
            "типовые",
            "типовые вед поз"
        }
    ),
    replace_errors = fnReplaceAllErrors(select_columns), //заменяем ошибки в таблице
    filter_nulls = Table.SelectRows(replace_errors, each ([журнал номер] <> null) and ([индекс] <> null)), //исключаем строки без ключа
    select_cols = Table.SelectColumns( //оставляем требуемые аттрибуты
        filter_nulls, 
        {
            "журнал номер",
            "индекс",
            "типовые",
            "типовые вед поз"
        }
    ),
    change_dtype = Table.TransformColumnTypes( //изменяем тип данных аттрибутов
        filter_nulls, 
        {
            {"журнал номер", type text}, 
            {"индекс", type text},
            {"типовые", type text}
        }
    ),
    norm_data = Table.TransformColumns( //нормализуем данные
        change_dtype,
        {
            {"журнал номер", each Text.Trim(Text.Clean(Text.Lower(_))), type text},
            {"индекс", each Text.Trim(Text.Clean(Text.Lower(_))), type text},
            {"типовые", each Text.Trim(Text.Clean(Text.Lower(_))), type text}
        }
    ),
    check_key_unique =
		let
			row_count = Table.RowCount(norm_data), //кол-во строк
			row_dcount = 
                Table.RowCount( //кол-во строк по уникальным позициям ключа
                    Table.Distinct(norm_data, {"индекс","журнал номер"})
                ),
			is_unique = 
                if row_count = row_dcount then 
                    norm_data 
                else 
                    error Error.Record(
                                "Таблица с кодировкой содиржит дубликаты строк.",
                                "Необходимо удалить дубликаты строк по ключу <индекс>, <журнал номер>"
                            )
		in
			is_unique
in
    check_key_unique