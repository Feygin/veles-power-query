/* 
    загружаем справочник проект
 */
let
    data = fnGetTableFromFile(dimension_path, [kind = "Sheet", name = "проект"]), //получаем данные листа проект в google sheets
    promote_header = Table.PromoteHeaders(data, [PromoteAllScalars = true]), //используем первую строку листа в качестве заголовка 
    select_cols = Table.SelectColumns(promote_header, {"проект", "проект краткий", "подпроект"}), //выбираем необходимые столбцы
    change_dtype = Table.TransformColumnTypes( //изменяем тип данных
        select_cols,
        {
            {"проект", type text}, 
            {"проект краткий", type text}, 
            {"подпроект", type text}
        }
    ),
    filldown_project = Table.FillDown(change_dtype, {"проект", "проект краткий"}), //заполняем отсутствующие наименования проекта из заголовков
    filter_nulls = Table.SelectRows(filldown_project, each [подпроект] <> null and [подпроект] <> ""), //удаляем пустые строки, в кач-ве условия брем поле подпроект
    duplicate_project_key = Table.DuplicateColumn(filter_nulls, "проект", "проект_dup"), //дублируем наименования проекта, подпроекта для формирования ключа
    duplicate_subproject_key = Table.DuplicateColumn(duplicate_project_key, "подпроект", "подпроект_dup"),
    clean_keys = fnCleanData(duplicate_subproject_key, [columns =  {"проект_dup", "подпроект_dup"}]), //нормализуем значения для ключа
    combine_key = Table.CombineColumns(clean_keys,{"проект_dup", "подпроект_dup"},Combiner.CombineTextByDelimiter("_", QuoteStyle.None),"проект_key"), //объединяем поля в композитный ключ
    check_pk = fnCheckPrimaryKey(combine_key, [column = "проект_key", file_name = "справочник google", table_name = "проект_2_0"]), //проверяем уникальность ключа
    add_sort = fnAddSort(check_pk, [columns = {"проект", "подпроект"}]), //добавляем сортировку значений по столбцам
    add_refresh_datetime = fnAddRefreshDateTime(add_sort, [column = "время обновления google"]) //добавляем время обновления базы
in
    add_refresh_datetime