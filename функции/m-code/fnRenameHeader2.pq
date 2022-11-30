/* 
    Цель: переименование столбцов в таблице согласно заданным значениям, 
        по дефолту изменяет применяет Trim, Lower, Clean на существующие столбцы
 */
 (source as table, _parameter as record) =>
    let
        // [
        renames = Record.Field(_parameter, "renames"), //список с переименованием столбцов
        prenormalize_header = Record.FieldOrDefault(_parameter, "prenormalize_header", true),
        table_name = Record.FieldOrDefault(_parameter, "table_name", "#таблица не задана"),
        file_name = Record.FieldOrDefault(_parameter, "file_name", "#файл не задан"),

        prenorm_header = //преднормализуем заголовки
            if prenormalize_header = true then
                Table.TransformColumnNames(source, each Text.Trim(Text.Lower(Text.Clean(_))))
            else 
                source,
        old_cols = Table.ColumnNames(prenorm_header), //список столбцов до нормализации
        new_cols = 
            List.Transform( //список столбцов после нормализации
                old_cols, 
                each List.ReplaceMatchingItems({_}, renames){0}
            ),
        zip_names = List.Zip({old_cols,new_cols}),
        rename = Table.RenameColumns(prenorm_header, zip_names),
        err = [
                is_distinct = List.IsDistinct(new_cols), //проверка нормализованных столбцов на наличие дубликатов
                list_to_table = Table.FromColumns({new_cols}, {"NewCols"}), //трансформируем лист нормализованных столбцов в таблицу 
                group_table = 
                    Table.Group( //группируем таблицу с подсчетом кол-ва строк для получения дубликтов ключа
                        list_to_table, "NewCols", 
                        {{"RowCount", Table.RowCount, type number}}
                    ),
                get_dup_rows = Table.SelectRows(group_table, each [RowCount] > 1), //получаем таблицу с дублирующимися ключами
                get_dup_list = Table.Column(get_dup_rows, "NewCols"), //получаем список дублирующихся ключей
                join_keys = Text.Combine(get_dup_list, "; "), //формируем текст с разделителем из списка дублирующихся ключей
                err = 
                    error Error.Record(
                                Text.Format("При нормализации заголовков в файле: ""#{0}"","
                                    & " таблице: ""#{1}"" появляются дубликаты столбцов ""#{2}""", {file_name, table_name, join_keys}
                                )
                            )
            ],
        result = if err[is_distinct] then rename else err[err]
        // ]
    in
        result