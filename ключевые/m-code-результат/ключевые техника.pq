let
    source = #"_трансформируем_данные",
    select_cols = Table.SelectColumns(source, {"имя файла", "лист", "Unpivot"}),
    filter = Table.SelectRows(select_cols, each [лист] = "тех.ресурсы"),
    remove_sheet = Table.RemoveColumns(filter, {"лист"}),
    remove_rows_with_err = Table.RemoveRowsWithErrors(remove_sheet),
    expand_cols = Table.ExpandTableColumn(
        remove_rows_with_err, 
        "Unpivot", 
        {"дата", "проект", "подпроект", "вид техники", "ед изм", "Value"}
    ),

    //transformation
    pivot = Table.Pivot(expand_cols, List.Distinct(expand_cols[#"ед изм"]), "ед изм", "Value", List.Sum), //пивот по столбцу единица измерения
    rename_cols = Table.RenameColumns(pivot,{{"факт (м.ч.)", "часы"}, {"факт (ед)", "техника"}}),
    remove_delta = Table.RemoveColumns(rename_cols,{"Δ", "план"}, MissingField.Ignore),

    //присоединяем таблицы их схемы
    //формируем ключи
    dup_project = Table.DuplicateColumn(remove_delta, "проект", "проект_dup"),
    dup_subproject = Table.DuplicateColumn(dup_project, "подпроект", "подпроект_dup"),
    dup_machinery = Table.DuplicateColumn(dup_subproject, "вид техники", "наименование техники_key"),
    clean_dups = Table.TransformColumns(
        dup_machinery,
        {
            {"проект_dup", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"подпроект_dup", each Text.Trim(Text.Clean(Text.Lower(_))), type text},
            {"наименование техники_key", each Text.Trim(Text.Clean(Text.Lower(_))), type text}
    }),
    create_project_key = Table.CombineColumns(clean_dups,{"проект_dup", "подпроект_dup"},Combiner.CombineTextByDelimiter("_", QuoteStyle.None),"проект_key"),
    change_dtype = Table.TransformColumnTypes(
        create_project_key, 
        {
            {"дата", type date},
            {"техника", type number},
            {"часы", type number}
        }
    ),
    //join схема tables
    join_calendar = Table.NestedJoin(change_dtype, {"дата"}, #"календарь", {"дата"}, "дата_joined", JoinKind.LeftOuter),
    expand_calendar = Table.ExpandTableColumn(join_calendar, "дата_joined", {"месяц год"}, {"схема.месяц год"}),
    join_project = Table.NestedJoin(expand_calendar, {"проект_key"}, #"проект", {"проект_key"}, "проект_joined", JoinKind.LeftOuter),
    expand_project = Table.ExpandTableColumn(join_project, "проект_joined", {"проект", "подпроект"}, {"схема.проект", "схема.подпроект"}),
    join_machinery = Table.NestedJoin(expand_project, {"наименование техники_key"}, #"техника", {"наименование техники_key"}, "техника_joined", JoinKind.LeftOuter),
    expand_machinery = Table.ExpandTableColumn(join_machinery, "техника_joined", {"наименование техники", "группа техники"}, {"схема.наименование техники", "схема.группа техники"}),

    add_refresh_date = fnAddRefreshDateTime(expand_machinery, [column = "время обновления база"]),
  
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
            "вид техники",
            "наименование техники_key",
            "схема.наименование техники",
            "схема.группа техники",
            "техника",
            "часы",
            "имя файла"
        }
    )
in
    select_final_cols