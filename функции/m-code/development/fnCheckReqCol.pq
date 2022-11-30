/* 
    Цель: Проверка на наличие в таблице столбцов из списка
    Параметры:
        Positional:
            source - проверяемая таблица
        Keyword:
            Optional:
                columns - список обязательных столбцов
                table_name - имя таблицы
                file_name - имя файла
                errors - поведение функции при наличии ошибок "record" / null
 */
(source as table, _parameter as record) =>
let
    columns = Record.Field(_parameter, "columns"), 
    table_name = Record.FieldOrDefault(_parameter, "table_name", "#таблица не задана"),
    file_name = Record.FieldOrDefault(_parameter, "file_name",  "#путь не задан"),
    errors = Record.FieldOrDefault(_parameter, "errors",  "raise"),

    req_cols_buffer = List.Buffer(columns),
    source_cols_buffer = List.Buffer(Table.ColumnNames(source)),
    has_req_cols = Table.HasColumns(source, req_cols_buffer), 
    missing_cols = 
        Text.Combine(
            List.Difference(req_cols_buffer,source_cols_buffer), 
            "; "
        ),
    err_msg = 
        Text.Format(
            "fnCheckReqCol: В файле: ""#{0}"" таблице: ""#{1}""  отсутствуют следующие обязательные столбцы: ""#{2}""", 
            {file_name, table_name, missing_cols}
        ),
    err_missing = error Error.Record( err_msg ),
    err_missing_record_true = 
        [
            файл = file_name,
            таблица = table_name,
            ошибка = "отсутствующие поля",
            ошибка_результат = true,
            ошибка_сообщение = null
        ],
    err_missing_record_false = 
        [
            файл = file_name,
            таблица = table_name,
            ошибка = "отсутствующие поля",
            ошибка_результат = false,
            ошибка_сообщение = err_msg
        ],
    result = 
        // if columns <> null then
            if errors = "raise" and has_req_cols then source
            else if errors = "raise" and not has_req_cols then err_missing
            else if errors = "record" and has_req_cols then err_missing_record_true
            else if errors = "record" and not has_req_cols then err_missing_record_false
            else ...
        // else 
        //     if errors = "raise" then source
        //     else if errors = "record" then err_missing_record_true
        //     else ...
in
    result


    