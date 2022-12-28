/* 
    загружаем справочник техника
 */
let
    data = fnGetTableFromFile(dimension_path, [kind = "Sheet", name = "техника"]), //получаем данные листа техника в google sheets
    promote_header = Table.PromoteHeaders(data, [PromoteAllScalars = true]), //используем первую строку листа в качестве заголовка
    select_cols = Table.SelectColumns(promote_header, {"наименование техники", "группа техники", "подгруппа техники"}), //выбираем необходимые столбцы
    change_dtype = Table.TransformColumnTypes( //изменяем тип данных
        select_cols,
        {
            {"наименование техники", type text},
            {"группа техники", type text},
            {"подгруппа техники", type text}
        }
    ),
    remove_empty_rows = Table.SelectRows(change_dtype, each ([наименование техники] <> null)), //удаляем пустые строки
    duplicate_key_col = Table.DuplicateColumn(remove_empty_rows, "наименование техники", "наименование техники_key"), //дублируем поля для ключа
    clean_key_col = fnCleanData(duplicate_key_col, [columns =  {"наименование техники_key"}]), //нормализуем ключ
    check_pk = fnCheckPrimaryKey(clean_key_col, [column = "наименование техники_key", file_name = "справочник google", table_name = "техника"]), //проверяем уникальность ключа
    add_sort = fnAddSort(check_pk, [columns = {"наименование техники", "группа техники"}]), //добавляем сортировку
    add_refresh_datetime = fnAddRefreshDateTime(add_sort, [column = "время обновления google"]) //добавляем время обновления
in
    add_refresh_datetime