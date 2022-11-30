let
    source_all_files = #"_все_файлы_папки",
    source_extracted = Table.SelectColumns(#"_transformation", {"имя файла", "лист", "статус извлечения"}),
    join = Table.NestedJoin(source_all_files, {"имя файла", "лист"}, source_extracted, {"имя файла", "лист"}, "_joined", JoinKind.LeftOuter),
    expand_status = Table.ExpandTableColumn(join, "_joined", {"статус извлечения"}),
    add_status_not_found = Table.ReplaceValue(expand_status,null,"Ошибка лист не найден",Replacer.ReplaceValue,{"статус извлечения"})
in
    add_status_not_found