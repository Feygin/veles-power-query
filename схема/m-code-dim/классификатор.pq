/* 
    загружаем справочник "классификатор"
 */
let
    data = fnGetTableFromFile(#"схема_путь", [kind = "Sheet", name = "классификатор"]), //извлекаем данные из листа классификатор 
    promote_header = Table.PromoteHeaders(data, [PromoteAllScalars = true]), //поднимаем первую строку в заголовок
    filter_nulls = Table.SelectRows(promote_header, each ([классификатор] <> null)), //исключаем пустые строки по аттрибуту ключа
    select_cols = Table.SelectColumns(filter_nulls, {"классификатор", "классификатор описание"}), //выбираем аттрибуты согласно спецификации
    change_dtype = Table.TransformColumnTypes(select_cols,{{"классификатор", type text}, {"классификатор описание", type text}}), //изменяем тип данных
    duplicate_classificator_key = Table.DuplicateColumn(change_dtype, "классификатор", "классификатор_key"), //дублируем поле с ключом
    clean_keys = fnCleanData(duplicate_classificator_key, [columns =  {"классификатор_key"}]), //нормализуем ключ
    check_pk = fnCheckPrimaryKey(clean_keys, [column = "классификатор_key", file_name = "справочник google", table_name = "классификатор_2_0"]), //проверяем уникальность ключа
    add_classificator_with_escr = Table.AddColumn(check_pk, "классификатор с описанием", each [классификатор] & " - " & [классификатор описание], type text), //добавляем пттрибут с наименованием классификатора 
    add_sort = fnAddSort(add_classificator_with_escr, [columns = {"классификатор"}]),
    add_refresh_datetime = fnAddRefreshDateTime(add_sort, [column = "время обновления google"])
in
    add_refresh_datetime