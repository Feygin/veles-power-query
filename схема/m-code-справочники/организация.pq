/* 
    загружаем справочник организация
 */
let
    data = fnGetTableFromFile(dimension_path, [kind = "Sheet", name = "организация"]), //извлекаем данные из соответствующего листа
    promote_header = Table.PromoteHeaders(data, [PromoteAllScalars = true]), //используем первую строку листа в качестве заголовка 
    select_cols = Table.SelectColumns(promote_header, {"организация", "организация без суб вм", "организация с суб вм", "источник"}), //выбираем необходимые столбцы
    change_dtype = Table.TransformColumnTypes( //изменяем тип данных
        select_cols,
        {
            {"организация", type text},
            {"организация без суб вм", type text},
            {"организация с суб вм", type text},
            {"источник", type text}
        }
    ),
    remove_empty_rows = Table.SelectRows(change_dtype, each ([организация] <> null)), //удаляем пустые строки
    duplicate_key_col = Table.DuplicateColumn(remove_empty_rows, "организация", "организация_key"), //дублируем поля для формирования ключа
    clean_key_col = fnCleanData(duplicate_key_col, [columns =  {"организация_key"}]), //нормализуем значения для ключа
    check_pk = fnCheckPrimaryKey(clean_key_col, [column = "организация_key", file_name = "справочник google", table_name = "организация_2_0"]), //проверяем уникальность ключа
    add_sort = fnAddSort(check_pk, [columns = {"организация", "организация без суб вм"}]), //добавляем сортировку
    add_refresh_datetime = fnAddRefreshDateTime(add_sort, [column = "время обновления google"]) //добавляем время обновления
in
    add_refresh_datetime