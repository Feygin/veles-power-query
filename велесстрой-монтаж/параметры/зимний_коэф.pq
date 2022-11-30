let
    source = Excel.CurrentWorkbook(){[Name="зимний_коэф"]}[Content],
    change_dtype = Table.TransformColumnTypes(source,{{"дата", type date}, {"зимний коэф", type number}}),
    filter_nulls = Table.SelectRows(change_dtype, each ([дата] <> null) and ([дата] <> "")),
    check_key_unique =
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