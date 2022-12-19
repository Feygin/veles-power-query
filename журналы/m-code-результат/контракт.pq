/* 
    из трансформированных данных извлекаем данные контракта
 */
let
    source = #"_трансформируем_данные", //ссылка на предыдущий шаг
    filter_successfull = Table.SelectRows(source, each [статус извлечения] = "Извлечено"), //выбираем файлы без ошибок
    //проверяем, что есть хотя бы один успешно извлеченный файл
    check_any_data = if Table.IsEmpty(filter_successfull) then error Error.Record("Ни один из файлов не был успешно трансформирован") else filter_successfull, 
    select_cols = Table.SelectColumns(check_any_data, {"имя файла", "FilterIndex"}), //оставляем столбец с имененм файла и результатом трансформации
    combine = Table.Combine(select_cols[FilterIndex]), //объединяем таблицы

    //функция для отобора контрактных столбцов и очищения названий от 
    //маркеров которые появились после объединения многострочной шапки
    fnSelectContractColumns =
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
                add_contract_marker = Table.AddColumn( //определяем какие столбцы оставляем в таблице контракт
                    to_table,
                    "фильтр",
                    each 
                        if Text.StartsWith([извлеченные столбцы],  "контракт^") then //если есть маркер контракт 
                            "v"
                        else if Text.StartsWith([извлеченные столбцы], "ркц ур") then //или это иерархия
                            "v"
                        else if ([извлеченные столбцы] = "имя файла") then //или имя файла
                            "v"
                        else 
                            null
                ),
                //убираем лишнее
                filter_cols = Table.SelectRows(add_contract_marker, each ([фильтр] = "v")),
        
                extract_header_name = Table.AddColumn( //извлекаем название столбцов из объединенной шапки
                    filter_cols,
                    "столбцы нормализованные",
                    each
                        if Text.StartsWith([извлеченные столбцы], "контракт^") then
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
                
                select_cols = Table.SelectColumns(source, cols_to_select), //выбираем контрактные столбцы
                rename_cols = Table.RenameColumns(select_cols, list_with_renames) //переименовываем 
            // ],
            in
                rename_cols,
    apply_column_slection = fnSelectContractColumns(combine), //применяем функцию 

    add_refresh_date = fnAddRefreshDateTime(apply_column_slection, [column = "время обновления база"]), //добавлем время обновления

    //задаем порядок столбцов согласно пользовательскому списку
    reorder_cols = Table.ReorderColumns(add_refresh_date, #"столбцы_контракт", MissingField.Ignore) 
in
    reorder_cols
