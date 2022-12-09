/* 
    выводим статус излечения и трансформации таблиц из файлов с ключевыми показателями
    если в каком-либо файле не была найдена таблица или возникла ошибка при трансформации, то этот файл
    появится в этом статусе с соответствующей меткой
 */
let
    //таблица со всеми файлами в папке
    all_files = [
        folder_files = Folder.Files(#"ключевые_путь"), //содержимое папки
        filter_subfolders = Table.SelectRows(folder_files, each ([Folder Path] = #"ключевые_путь" & "\")), //исключаем вложенные папки
        filter_hidden = Table.SelectRows(filter_subfolders, each [Attributes]?[Hidden]? = false), //исключаем скрытые файлы
        folder_file_names = Table.SelectColumns(filter_hidden,{"Name"}), //оставляем поле с имнем файла
        rename_col = Table.RenameColumns(folder_file_names,{{"Name", "имя файла"}}), //переименовываем поле с именем файла
        add_list_with_result_sheets = Table.AddColumn(rename_col, "лист", each {"ключевые объемы", "лр по видам работ", "тех.ресурсы"}), //добавляем список допустимых имен листов в файле 
        expand_list = Table.ExpandListColumn(add_list_with_result_sheets, "лист") //unpivot листа с допустимыми именами листов
    ][expand_list],

    //таблица с ошибками при трансформации
    invalid_data = 
        [
            source = #"_трансформируем_данные", //ссылка на шаг с трансформацией данных
            select_cols = Table.SelectColumns(source, {"имя файла", "лист", "Unpivot"}), //оставляем результат трансформации и метаданные
            keep_rows_with_erros = Table.SelectRowsWithErrors(select_cols), //оставляем строки с ошибками при трансформации
            add_status = Table.AddColumn(keep_rows_with_erros, "статус", each "ошибки при извлечении"), //добавляем поле со статусом 
            select_result_cols = Table.SelectColumns(add_status,{"имя файла", "лист", "статус"})
        ]
        [select_result_cols],

    //таблица с извлеченными и преобразованными файлами
    valid_data = [
        source = #"_трансформируем_данные", //ссылка на шаг с трансформацией данных
        select_cols = Table.SelectColumns(source, {"имя файла", "лист", "Unpivot"}), //оставляем результат трансформации и метаданные
        remove_rows_with_err = Table.RemoveRowsWithErrors(select_cols), //удаляем строки с ошибками при трансформации
        add_status = Table.AddColumn(remove_rows_with_err, "статус", each "извлечено"), //добавляем поле со статусом 
        select_result_cols = Table.SelectColumns(add_status,{"имя файла", "лист", "статус"})
    ]
    [select_result_cols],

    union_valid_invalid = Table.Combine({valid_data, invalid_data}), //объединяем статусы

    all_join_status = Table.NestedJoin(all_files, {"имя файла", "лист"}, union_valid_invalid, {"имя файла", "лист"}, "_status", JoinKind.LeftOuter), //объединяем все файлы со статусами
    expand_status = Table.ExpandTableColumn(all_join_status, "_status", {"статус"}, {"статус"}), //получаем статусы из объединенной таблице

    replace_nulls_with_missing_status = Table.ReplaceValue(expand_status, null,"не найдено",Replacer.ReplaceValue,{"статус"}) //если лист не был извлечен и не содержал ошибок значит он отсутствовал в файле
in
    replace_nulls_with_missing_status