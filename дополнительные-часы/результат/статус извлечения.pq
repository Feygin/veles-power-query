let
    Source = Table.NestedJoin(_expected_all_files, {"имя файла"}, _extracted, {"имя файла"}, "_extracted", JoinKind.LeftOuter),
    #"Expanded _extracted" = Table.ExpandTableColumn(Source, "_extracted", {"таблица", "статус"}, {"таблица", "статус"}),
    #"Replaced Value" = Table.ReplaceValue(#"Expanded _extracted",null,"не найдено",Replacer.ReplaceValue,{"статус"})
in
    #"Replaced Value"