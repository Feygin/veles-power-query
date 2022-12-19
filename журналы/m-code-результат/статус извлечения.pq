let
    //получаем таблицу в которой показаны файлы и листы, которые ожидаем получить при выполнении запроса
    source = Folder.Files(#"журналы_путь"), //содержимое папки с журналами
    filter_subfolders = Table.SelectRows(source, each ([Folder Path] = #"журналы_путь" & "\")), //исключаем подпапки
    filter_hidden = Table.SelectRows(filter_subfolders, each [Attributes]?[Hidden]? = false), //исключаем скрытые файлы
    select_cols = Table.SelectColumns(filter_hidden,{"Name"}), //оставлем аттрибут с именем файла
    rename_col = Table.RenameColumns(select_cols,{{"Name", "имя файла"}}), //переименовываем название столбцы с аттрибутом имени файла
    norm_names = Table.TransformColumns( //нормализуем имя файла
        rename_col,
        {
            {"имя файла", each Text.Trim(Text.Lower(_))}
        }
    ),
    add_result_sheet = Table.AddColumn(norm_names, "лист", each #"PrSheetName"), //добавляем столбец с именем листа который должен быть извлечен из каждого файла

    //получаем таблицу с успешно извлеченными файлами
    source_extracted = Table.SelectColumns(#"_трансформируем_данные", {"имя файла", "лист", "статус извлечения"}), //из шага с трансформацией таблиц оставляем аттрибуты и статус извлечения
    join = Table.NestedJoin(add_result_sheet, {"имя файла", "лист"}, source_extracted, {"имя файла", "лист"}, "_joined", JoinKind.LeftOuter), //объединяем ожидаемый результат и фактический
    expand_status = Table.ExpandTableColumn(join, "_joined", {"статус извлечения"}), //раскрываем статус извлечения
    add_status_not_found = Table.ReplaceValue(expand_status,null,"Ошибка: недопустимое имя файла или листа",Replacer.ReplaceValue,{"статус извлечения"}) //если статус отсутвует, значит файл не был извлечен
in
    add_status_not_found