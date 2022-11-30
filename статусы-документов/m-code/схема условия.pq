let
	schema_buffer = Table.Buffer(#"схема таблицы"[#"схема"]),
	schema_conditions = 
		[
			#"поле" = SubCreateHierarchyFromSchema(schema_buffer, [filter = "true", path = {"таблица"}, value = "поле"]),
			#"преобразовать тип данных" = SubCreateHierarchyFromSchema(schema_buffer, [filter = "row[преобразовать тип данных]<>null", path = {"таблица"}, value = "поле"]),
			#"тип данных" = SubCreateHierarchyFromSchema(schema_buffer, [filter = "row[преобразовать тип данных]<>null", path = {"таблица"}, value = "тип данных"])
		]
in
    schema_conditions