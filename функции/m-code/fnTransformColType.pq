/* 
	Функция для изменения типа данных в таблице согласно списку столбцов и текстовой репрезентации типа данных. Поддерживает режим для замены подмножества столбцов из заданного списка.
 */
(
    source as table, _parameter as record
) as table =>
let
	columns = Record.Field(_parameter, "columns"), //list или record для преобразования типа данных 
	columns_type = Record.FieldOrDefault(_parameter, "columns_type", null), //если columns в формате list, задаем list с dtype 
    transform_subset = Record.FieldOrDefault(_parameter, "transform_subset",  false),

	record_with_facets = 
		[
			Number.Type = Number.Type, 
			Currency.Type = Currency.Type, 
			Int64.Type = Int64.Type, 
			Percentage.Type = Percentage.Type,
			DateTime.Type = DateTime.Type, 
			Date.Type = Date.Type, 
			Time.Type = Time.Type, 
			DateTimeZone.Type = DateTimeZone.Type, 
			Duration.Type = Duration.Type, 
			Text.Type = Text.Type, 
			Logical.Type = Logical.Type, 
			Binary.Type = Binary.Type, 
			Any.Type = Any.Type
		],
	buffer_columns_and_types = 
			[
				columns = List.Buffer(columns),
				text_types = List.Buffer(columns_type)
			],
	zip_columns_with_types = 
			let
				text_types_to_types = List.Transform(buffer_columns_and_types[text_types], each Expression.Evaluate(_, record_with_facets)),
				zip_columns_with_types = List.Zip({buffer_columns_and_types[columns], text_types_to_types})
			in
				zip_columns_with_types,
	fnGetTransformationSubset = //функция для фильтрации списка столбцов с типом данных zip_columns_with_types
		(source_columns)=> //список столбцов источника
			(zip_list)=> //список из zip_columns_with_types
				let
					zip_column = zip_list{0},
					filter = List.Contains(source_columns, zip_column) //если столбец из zip_columns_with_types присутствует в списке столбцов источника
				in //тоглда возвращает true
					filter,
	select_subset = 
		if transform_subset = true then //случай изменения типа данных для общих столбцов
			let
				source_columns = List.Buffer(Table.ColumnNames(source)),
				get_subset = List.Select(zip_columns_with_types, fnGetTransformationSubset(source_columns))
			in
				get_subset
		else 
			zip_columns_with_types,
	transform_col_types = Table.TransformColumnTypes(source,select_subset)
in
    transform_col_types