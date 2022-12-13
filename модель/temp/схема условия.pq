let
	schema_buffer = Table.Buffer(#"content"{[Item = "схема"]}[Data]),
	schema_conditions = 
		[
			#"поле" = fnCreateRecordHierarchy(schema_buffer, [path = {"таблица"}, value = "поле"]),
			#"поле number" = 
				fnCreateRecordHierarchy(schema_buffer, 
					[
						filter = "row[тип данных] = ""Number.Type""", 
						path = {"таблица"}, value = "поле"
					]
				),
			#"тип данных" = 
				fnCreateRecordHierarchy(schema_buffer, 
					[
						path = {"таблица", "поле"}, value = "тип данных", squeeze = true
					]
				),
			#"модель исключить" = fnCreateRecordHierarchy(schema_buffer, [filter = "row[модель исключить]<>null", path = {"таблица"}, value = "поле"]),
			#"модель нормализация" = fnCreateRecordHierarchy(schema_buffer, [filter = "row[модель нормализация]<>null", path = {"таблица"}, value = "поле"]),
			#"модель замена null" = fnCreateRecordHierarchy(schema_buffer, [filter = "row[модель замена null]<>null", path = {"таблица"}, value = "поле"]),
			#"модель сортировка" = fnCreateRecordHierarchy(schema_buffer, [filter = "row[модель сортировка]<>null", path = {"таблица"}, value = "поле"]),
			#"модель срез" = fnCreateRecordHierarchy(schema_buffer, [filter = "row[модель срез]<>null", path = {"таблица"}, value = "поле"]),
			#"шаблон ввод" = fnCreateRecordHierarchy(schema_buffer, [filter = "row[шаблон исключить]=null", path = {"таблица", "поле"}, value = "шаблон значение", squeeze = true]),
			#"шаблон полный" = fnCreateRecordHierarchy(schema_buffer, [path = {"таблица", "поле"}, value = "шаблон значение", squeeze = true]),
			#"системная строка" = fnCreateRecordHierarchy(schema_buffer, [filter = "row[шаблон значение]<>null", path = {"таблица", "поле"}, value = "шаблон значение", squeeze = true])
		]
in
    schema_conditions