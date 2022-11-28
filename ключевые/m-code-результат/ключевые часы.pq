let
    source = #"_transformation",
    select_cols = Table.SelectColumns(source, {"имя файла", "лист", "Unpivot"}),
    filter = Table.SelectRows(select_cols, each [лист] = "лр по видам работ"),
    remove_sheet = Table.RemoveColumns(filter, {"лист"}),
    remove_rows_with_err = Table.RemoveRowsWithErrors(remove_sheet),
    expand_cols = Table.ExpandTableColumn(
        remove_rows_with_err, 
        "Unpivot", 
        {"дата", "проект", "подпроект", "организация", "ключевые", "ключевые ед изм", "ед изм", "Value"}
    ),

    //transformation
    replace_null_units = Table.ReplaceValue(expand_cols, each null, each "-", Replacer.ReplaceValue, {"ед изм"}),
    pivot = Table.Pivot(expand_cols, List.Distinct(expand_cols[#"ед изм"]), "ед изм", "Value", List.Sum), //пивот по столбцу единица измерения
    rename_cols = Table.RenameColumns(pivot,{{"ч.ч.", "часы"}, {"чел.", "люди"}, {"ключевые ед изм", "ед изм"}}),

    //присоединяем таблицы их схемы
    //формируем ключи
    dup_project = Table.DuplicateColumn(rename_cols, "проект", "проект_dup"),
    dup_subproject = Table.DuplicateColumn(dup_project, "подпроект", "подпроект_dup"),
    dup_subcontractor = Table.DuplicateColumn(dup_subproject, "организация", "организация_key"),
    dup_kluchevie = Table.DuplicateColumn(dup_subcontractor, "ключевые", "ключевые_dup"),
    dup_unit = Table.DuplicateColumn(dup_kluchevie, "ед изм", "ед изм_dup"),
    clean_dups = Table.TransformColumns(
        dup_unit,
        {
            {"проект_dup", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"подпроект_dup", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"организация_key", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"ключевые_dup", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"ед изм_dup", each Text.Trim(Text.Clean(Text.Lower(_))), type text}
    }),
    create_project_key = Table.CombineColumns(clean_dups,{"проект_dup", "подпроект_dup"},Combiner.CombineTextByDelimiter("_", QuoteStyle.None),"проект_key"),
    create_kluchevie_key = Table.CombineColumns(create_project_key,{"ключевые_dup", "ед изм_dup"},Combiner.CombineTextByDelimiter("_", QuoteStyle.None),"ключевые_key"),
    normalize_subproject_key = fnReplaceMultipleValues(create_kluchevie_key, [columns = {"организация_key"}, replacement = #"нормализация"]),
    change_dtypes = Table.TransformColumnTypes(
        normalize_subproject_key, 
        {
            {"дата", type date},
            {"люди", type number},
            {"часы", type number}
        }
    ),
    //join схема tables
    join_calendar = Table.NestedJoin(change_dtypes, {"дата"}, #"календарь", {"дата"}, "дата_joined", JoinKind.LeftOuter),
    expand_calendar = Table.ExpandTableColumn(join_calendar, "дата_joined", {"месяц год"}, {"схема.месяц год"}),
    join_project = Table.NestedJoin(expand_calendar, {"проект_key"}, проект, {"проект_key"}, "проект_joined", JoinKind.LeftOuter),
    expand_project = Table.ExpandTableColumn(join_project, "проект_joined", {"проект", "подпроект"}, {"схема.проект", "схема.подпроект"}),
    join_subcontractor = Table.NestedJoin(expand_project, {"организация_key"}, организация, {"организация_key"}, "организация_joined", JoinKind.LeftOuter),
    expand_subconractor = Table.ExpandTableColumn(join_subcontractor, "организация_joined", {"организация"}, {"схема.организация"}),
    join_kluchevie = Table.NestedJoin(expand_subconractor, {"ключевые_key"}, ключевые, {"ключевые_key"}, "ключевые_joined", JoinKind.LeftOuter),
    expand_kluchevie = Table.ExpandTableColumn(
        join_kluchevie, 
        "ключевые_joined", 
        {
            "ключевые ур0 наименование", 
            "ключевые ур1 наименование",
            "типовые_key"
        }, 
        {
            "схема.ключевые ур0 наименование", 
            "схема.ключевые ур1 наименование",
            "схема.типовые_key"
        }
    ),
    join_tipovie = Table.NestedJoin(expand_kluchevie, {"схема.типовые_key"}, #"типовые", {"типовые_key"}, "типовые_joined", JoinKind.LeftOuter),
    expand_tipovie = Table.ExpandTableColumn(
        join_tipovie, 
        "типовые_joined", 
        {
            "типовые наименование",
            "типовые ур0 наименование", 
            "типовые ур1 наименование", 
            "типовые ур2 наименование"
        }, 
        {
            "схема.типовые наименование",
            "схема.типовые ур0 наименование", 
            "схема.типовые ур1 наименование", 
            "схема.типовые ур2 наименование"
        }
    ),
    add_refresh_date = fnAddRefreshDateTime(expand_tipovie, [column = "время обновления база"]),
    select_final_cols = Table.SelectColumns(
        add_refresh_date,
        {
            "дата",
            "схема.месяц год",
            "проект",
            "подпроект",
            "проект_key",
            "схема.проект",
            "схема.подпроект",
            "организация",
            "организация_key",
            "схема.организация",
            "ключевые",
            "ед изм",
            "ключевые_key",
            "схема.ключевые ур0 наименование", 
            "схема.ключевые ур1 наименование",
            "схема.типовые_key",
            "схема.типовые наименование",
            "схема.типовые ур0 наименование", 
            "схема.типовые ур1 наименование", 
            "схема.типовые ур2 наименование",
            "люди",
            "часы",
            "имя файла",
            "время обновления база"
        }
    )
in
    select_final_cols