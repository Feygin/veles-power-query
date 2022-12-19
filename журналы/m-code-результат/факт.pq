/* 
    из трансформированных данных извлекаем данные факта
 */
let
    source = #"_трансформируем_данные", //ссылка на предыдущий шаг
    filter_successfull = Table.SelectRows(source, each [статус извлечения] = "Извлечено"), //выбираем файлы без ошибок
    //проверяем, что есть хотя бы один успешно извлеченный файл
    check_any_data = if Table.IsEmpty(filter_successfull) then error Error.Record("Ни один из файлов не был успешно трансформирован") else filter_successfull,
    select_cols = Table.SelectColumns(check_any_data, {"имя файла", "FilterIndex"}), //оставляем столбец с имененм файла и результатом трансформации
    combine = Table.Combine(select_cols[FilterIndex]), //объединяем таблицы

    //функция для отобора столбцов факта и очищения названий от 
    //маркеров которые появились после объединения многострочной шапки
    fnSelectFactColumns =
        (source)=>
            let
            // [ //для debug
                CONTRACT_KEYWORD = "контракт^",
                FACT_KEYWORD = "факт^",
                FACT_EXCLUDE_KEYWORD = "^^факт исключить",
                HIERARCHY_KEYWORD =  "ркц ур",
                FILENAME = "имя файла",

                cols = Table.ColumnNames(source), //список текущих столбцов таблицы
                to_table = Table.FromColumns({cols}, {"извлеченные столбцы"}), //преобразовываем список столбцов -> в таблицу
                add_fact_marker = Table.AddColumn( //определяем какие столбцы оставляем в таблице факт
                    to_table,
                    "фильтр",
                    each 
                        if Text.StartsWith([извлеченные столбцы], "факт^") then //если есть маркер факт
                            "v"
                        else if Text.StartsWith([извлеченные столбцы], "контракт^") and not Text.EndsWith([извлеченные столбцы], "^^факт исключить") then //или маркер контракт без метки исключить
                            "v"
                        else if Text.StartsWith([извлеченные столбцы], "ркц ур") then //или это иерархия
                            "v"
                        else if ([извлеченные столбцы] = "имя файла") then //или это имя файла
                            "v"
                        else 
                            null
                ),
                
                //убираем лишнее
                filter_cols = Table.SelectRows(add_fact_marker, each ([фильтр] = "v")),
        
                extract_header_name = Table.AddColumn( //извлекаем название столбцов из объединенной шапки
                    filter_cols,
                    "столбцы нормализованные",
                    each
                        if Text.StartsWith([извлеченные столбцы], "факт^") then
                            Text.AfterDelimiter([извлеченные столбцы], "факт^")
                        else if Text.StartsWith([извлеченные столбцы], "контракт^") then
                            Text.BetweenDelimiters([извлеченные столбцы], "^", "^^")
                        else 
                            [извлеченные столбцы]
                ),
                //список ненормализованных контрактных столбцов
                //его используем в фукнции которая отбирает столбцы
                cols_to_select = extract_header_name[извлеченные столбцы], 
                //список из списков для переименования столбцов
                list_with_renames = Table.ToRows(
                    extract_header_name[[извлеченные столбцы], [столбцы нормализованные]]
                ),
                
                select_cols = Table.SelectColumns(source, cols_to_select), //выбираем столбцы факта
                rename_cols = Table.RenameColumns(select_cols, list_with_renames) //переименовываем 
            // ],
            in
                rename_cols,
    apply_column_slection = fnSelectFactColumns(combine), //отбираем столбцы

    unpivot = fnUnpivot(apply_column_slection), //unpivot месячной части

    add_refresh_date = fnAddRefreshDateTime(unpivot, [column = "время обновления база"]), //добавлем время обновления

    reorder_cols = Table.ReorderColumns(add_refresh_date, #"столбцы_факт", MissingField.Ignore) //меням расположение столбцов согласно пользовательскому списку
in
    reorder_cols