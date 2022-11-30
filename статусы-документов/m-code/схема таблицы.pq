let
    dimension_content = Excel.Workbook(Web.Contents("https://docs.google.com/spreadsheets/d/1WyM00ui1G3MgvEncRO4yc_Co6E0aLrTBsmPgWo0rQYU/export?format=xlsx"), null, true),
    calendar_content = Excel.Workbook(Web.Contents("https://docs.google.com/spreadsheets/d/1WpSbO6YnqWHpUZviYVqp2DwAklTg7baE-qzm1RTm0OM/export?format=xlsx"), null, true),
    vks_status_content = Excel.Workbook(Web.Contents("https://docs.google.com/spreadsheets/d/1H6kGqe1T-MjuLijTOUDu-oVYS9lA08-MivwKF486A-M/export?format=xlsx"), null, true),
    et1_status_content = Excel.Workbook(Web.Contents("https://docs.google.com/spreadsheets/d/1jBCwy0j8A6tdhj6Dkg4nTBD4C7Nejkpds7y2Mk-Dz5s/export?format=xlsx"), null, true),    
    extra_hours_status_content = Excel.Workbook(Web.Contents("https://docs.google.com/spreadsheets/d/1Uf72uy-Hdq6GiueGrQkW1ukS_9QbB6rm-0ygDhBSm2A/export?format=xlsx"), null, true),
    fnGetTableFromGoogleSheetAndFilterEmptyRows = //функция поднимающая заголовки и отсекающая незаполненные строки для google sheet
        (source)=>
            let
                buffer = Table.Buffer(source),
                promote_header = Table.PromoteHeaders(buffer, [PromoteAllScalars=true]), //поднимаем заголовки
                fnFilterNulls = //функция фильтрующая незаполненные ячейки в 1 столбце
                    (row)=>
                        let
                            first_column_value = List.First(Record.ToList(row)) //извлекаем значение первого столбца таблицы
                        in
                            first_column_value <> null and first_column_value <> "", //фильтруем незаполненные ячейки
                filter_nulls = Table.SelectRows(promote_header, fnFilterNulls) //фильтруем незаполненные строки
            in
                filter_nulls,
    fnGetGoogleSheetsByDate = //функция объединяющая таблицы из листов за последние 3 месяца
        (source, month_diff as number)=>
            let
                filter_sheets = Table.SelectRows(source, each ([Kind] = "Sheet")), //отбираем листы
                dtype_to_date = Table.TransformColumnTypes(filter_sheets,{{"Item", type date}}), //меняем тип данных на date
                remove_error_rows = Table.RemoveRowsWithErrors(dtype_to_date, {"Item"}), //удаляем строки с ошибками
                remove_null_rows = Table.SelectRows(remove_error_rows, each [Item] <> null),
                filter_by_date = Table.SelectRows(remove_null_rows, each Date.IsInCurrentMonth([Item]) or Date.IsInPreviousNMonths([Item], month_diff))
            in
                filter_by_date,
    result = 
        [
            проект = fnGetTableFromGoogleSheetAndFilterEmptyRows(dimension_content{[Kind = "Sheet", Item = "проект"]}[Data]),
            организация = fnGetTableFromGoogleSheetAndFilterEmptyRows(dimension_content{[Kind = "Sheet", Item = "организация"]}[Data]),
            договор = fnGetTableFromGoogleSheetAndFilterEmptyRows(dimension_content{[Kind = "Sheet", Item = "договор"]}[Data]),
            календарь = fnGetTableFromGoogleSheetAndFilterEmptyRows(calendar_content{[Kind = "Sheet", Item = "календарь"]}[Data]),
            вкс = 
                let
                    filter_sheets_by_date = fnGetGoogleSheetsByDate(vks_status_content, 2),
                    get_tables = Table.TransformColumns(filter_sheets_by_date, {"Data", fnGetTableFromGoogleSheetAndFilterEmptyRows}), //подготавливаем таблицы
                    combine_tables = Table.Combine(get_tables[Data]) //объединяем таблица
                in
                    combine_tables,
            ет1 = 
                let
                    filter_sheets_by_date = fnGetGoogleSheetsByDate(et1_status_content, 2),
                    get_tables = Table.TransformColumns(filter_sheets_by_date, {"Data", fnGetTableFromGoogleSheetAndFilterEmptyRows}), //подготавливаем таблицы
                    combine_tables = Table.Combine(get_tables[Data]) //объединяем таблица
                in
                    combine_tables,
            доп_часы = 
                let
                    filter_sheets_by_date = fnGetGoogleSheetsByDate(extra_hours_status_content, 6),
                    get_tables = Table.TransformColumns(filter_sheets_by_date, {"Data", fnGetTableFromGoogleSheetAndFilterEmptyRows}), //подготавливаем таблицы
                    combine_tables = Table.Combine(get_tables[Data]) //объединяем таблица
                in
                    combine_tables
        ]
in
    result