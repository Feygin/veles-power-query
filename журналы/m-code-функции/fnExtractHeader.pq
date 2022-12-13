/* 
    нормализаует и объединяет многострочную шапку журнала, которую задает пользователь
    удаляет столбцы для которых пользователь не задал значения
 */
 (source as table) =>
    let
    // [
        HEADER_LENGTH = 4, //количество строк многострочной шапки
        NULL_COLUMN_COMBINED = "^^^", //значение объединенной многострочной шапки у которой все строки содержат null

        get_header = Table.FirstN(source, HEADER_LENGTH), //оставляем строки с шапкой
        transpose = Table.Transpose(get_header), //транспонируем шапку
        rename_columns = 
            Table.RenameColumns( //переименовываем заголовки транспонированной шапки
                transpose, //согласно их предназначению
                {
                    {"Column1", "тип заголовка"},
                    {"Column2", "имя заголовка"},
                    {"Column3", "дата"},
                    {"Column4", "идентификатор"}
                }
            ),
        dtype_to_date = Table.TransformColumnTypes( //преобразовываем столбец шапки с датами в тип date
                rename_columns, //преобразование необходимо, чтобы избавиться от врменной части
                {
                    {"дата", type date}
                }
            ),
        dtype_to_text = 
            Table.TransformColumnTypes( //изменяем тип данных шапки в текст, чтобы выполнить нормализацию и объединение
                dtype_to_date,
                {
                    {"тип заголовка", type text},
                    {"имя заголовка", type text},
                    {"дата", type text}, 
                    {"идентификатор", type text}
                }
            ),
        fnNormalizeText = (val)=> Text.Trim(Text.Clean(Text.Lower(val))), //ф-ция для нормализации текста
        normalize_text = 
            Table.TransformColumns( //нормализуем текстовые столбцы шапки
                dtype_to_text,
                {
                    {"тип заголовка", fnNormalizeText, type text},
                    {"имя заголовка", fnNormalizeText, type text},
                    {"идентификатор", fnNormalizeText, type text}
                }
            ),
        combine_header = //объединяем строки шапки
            Table.CombineColumns(
                normalize_text, 
                {
                    "тип заголовка",
                    "имя заголовка",
                    "дата",
                    "идентификатор"
                },
                Combiner.CombineTextByDelimiter("^"),
                "объединенный заголовок"
            ),
        transpose_back = Table.Transpose(combine_header), //транспонируем обратно
        combine_source_with_header = Table.Combine({transpose_back, source}), //объединяем шапку с данными
        promote = Table.PromoteHeaders(combine_source_with_header, [PromoteAllScalars = true]), //поднимаем шапку в заголовок
        remove_header_rows = Table.Skip(promote,4), //удаляем из таблицы исходную шапку
        columns_to_remove = //получаем список столбцов для удаления 
            List.Select( //столбец удаляется если все строки многострочной шапки для него отсутствуют
                List.Buffer(
                    Table.ColumnNames(remove_header_rows)
                ),
                each Text.StartsWith(_, NULL_COLUMN_COMBINED)
            ),
        remove_columns = Table.RemoveColumns(remove_header_rows, columns_to_remove) //удаляем столбцы
    // ]
    in
        remove_columns