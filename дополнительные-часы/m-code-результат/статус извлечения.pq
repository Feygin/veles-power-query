/* 
    выводим статус излечения файлов
    в нем мы проверяем, что из всех файлов были извлечены таблицы
    если таблица не была извлечана 
 */
let
    //таблица со всеми файлоами в папке
    folder_files = Folder.Files(#"дополнительные_часы_путь"), //содержимое папки
    filter_subfolders = Table.SelectRows(folder_files, each ([Folder Path] = #"дополнительные_часы_путь" & "\")), //исключаем вложенные папки
    filter_hidden = Table.SelectRows(filter_subfolders, each [Attributes]?[Hidden]? = false), //исключаем скрытые файлы
    select_folder_files = Table.SelectColumns(filter_hidden,{"Name"}), //оставляем поле с имнем файла
    rename_folder_files = Table.RenameColumns(select_folder_files,{{"Name", "имя файла"}}), //переименовываем поле с именем файла

    //таблица с извлеченными файлами
    select_cols = Table.SelectColumns(#"_извлекаем_содержимое", {"имя файла", "таблица"}), //таблица с файлами из которых извлекли таблицы
    add_status = Table.AddColumn(select_cols, "статус", each "извлечено"), //добавляем поле со статусом

    //объединяем результат
    join = Table.NestedJoin(rename_folder_files, {"имя файла"}, add_status, {"имя файла"}, "_extracted", JoinKind.LeftOuter),
    expand = Table.ExpandTableColumn(join, "_extracted", {"таблица", "статус"}, {"таблица", "статус"}),
    replace_null_status = Table.ReplaceValue(expand, null,"не найдено",Replacer.ReplaceValue,{"статус"})
in
    replace_null_status