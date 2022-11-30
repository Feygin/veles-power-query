let
    source = Excel.CurrentWorkbook(){[Name="кодировка"]}[Content],
    replace_errors = fnReplaceAllErrors(source),
    filter_nulls = Table.SelectRows(replace_errors, each ([журнал номер] <> null) and ([индекс] <> null)),
    change_dtype = Table.TransformColumnTypes(
        filter_nulls, 
        {
            {"журнал номер", type text}, 
            {"индекс", type text},
            {"типовые", type text},
            {"сборник нормативов", type text}
        }
    ),
    norm_codes = Table.TransformColumns(
        change_dtype,
        {
            {"типовые", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"сборник нормативов", each Text.Trim(Text.Clean(Text.Lower(_))), type text}
    }),
    check_key_unique =
		let
			row_count = Table.RowCount(norm_codes), //кол-во строк
			row_dcount = 
                Table.RowCount( //кол-во строк по уникальным позициям ключа
                    Table.Distinct(norm_codes, {"индекс","журнал номер"})
                ),
			is_unique = 
                if row_count = row_dcount then 
                    norm_codes 
                else 
                    error Error.Record(
                                "Таблица с кодировкой содиржит дубликаты строк.",
                                "Необходимо удалить дубликаты строк по ключу <индекс>, <журнал номер>"
                            )
		in
			is_unique
in
    check_key_unique