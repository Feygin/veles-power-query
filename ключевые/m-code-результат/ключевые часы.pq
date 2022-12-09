/* 
    объединяем преобразованные таблицы с ключевыми часами,
    трансформируем аттрибуты ед изм (ч.ч., часы) в столбцы,
    формируем ключи и обогащаем данными из схема
 */
let
    source = #"_трансформируем_данные", //ссылка на предыдущий шаг
    select_cols = Table.SelectColumns(source, {"имя файла", "лист", "Unpivot"}), //оставляем поля с данными и их метаданными
    filter = Table.SelectRows(select_cols, each [лист] = "лр по видам работ"), //оставляем строки с ключевыми часами
    rename_sheet_attr = Table.RenameColumns(filter, {{"лист", "имя листа"}}), //переименовываем поле с именем листа
    remove_rows_with_err = Table.RemoveRowsWithErrors(rename_sheet_attr), //удаляем строки с ошибками
    expand_cols = Table.ExpandTableColumn( //объединяем содержимое
        remove_rows_with_err, 
        "Unpivot", 
        {"дата", "проект", "подпроект", "организация", "ключевые", "ключевые ед изм", "ед изм", "Value"}
    ),

    //pivot
    replace_dots_in_nums = fnReplaceSymbols( //заменяем "." на "," в числовых столбцах, чтобы при преобразовании
        expand_cols, //типа данных не появились ошибки
        [columns = {"Value"}, replacement = {{".", ","}}] 
    ),
    change_dtypes = Table.TransformColumnTypes( //изменяем типы данных
        replace_dots_in_nums, 
        {
            {"дата", type date},
            {"Value", type number}
        }
    ),
    pivot = Table.Pivot(change_dtypes, List.Distinct(expand_cols[#"ед изм"]), "ед изм", "Value", List.Sum), //пивот по столбцу единица измерения
    rename_cols = Table.RenameColumns(pivot,{{"ч.ч.", "часы"}, {"чел.", "люди"}, {"ключевые ед изм", "ед изм"}}), //переименовываем столбцы со значением часов

    //формируем ключи
    dup_project = Table.DuplicateColumn(rename_cols, "проект", "проект_dup"), //дублируем поля по которым создаем ключ
    dup_subproject = Table.DuplicateColumn(dup_project, "подпроект", "подпроект_dup"),
    dup_subcontractor = Table.DuplicateColumn(dup_subproject, "организация", "организация_key"),
    dup_kluchevie = Table.DuplicateColumn(dup_subcontractor, "ключевые", "ключевые_dup"),
    dup_unit = Table.DuplicateColumn(dup_kluchevie, "ед изм", "ед изм_dup"),
    clean_dups = Table.TransformColumns( //нормализуем продублированные поля
        dup_unit,
        {
            {"проект_dup", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"подпроект_dup", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"организация_key", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"ключевые_dup", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"ед изм_dup", each Text.Trim(Text.Clean(Text.Lower(_))), type text}
    }),
    create_project_key = Table.CombineColumns(clean_dups,{"проект_dup", "подпроект_dup"},Combiner.CombineTextByDelimiter("_", QuoteStyle.None),"проект_key"), //создаем композитный ключ для проекта
    create_kluchevie_key = Table.CombineColumns(create_project_key,{"ключевые_dup", "ед изм_dup"},Combiner.CombineTextByDelimiter("_", QuoteStyle.None),"ключевые_key"), //создаем композитный ключ для ключевых
    normalize_subproject_key = fnReplaceMultipleValues(create_kluchevie_key, [columns = {"организация_key"}, replacement = #"нормализация"]), //заменям значения в столбце организация согласно таблице переименований

    //заменяем . на , в числовых полях и изменяем тип данных
    //обогащаем данные значениями из схемы
    join_calendar = Table.NestedJoin(normalize_subproject_key, {"дата"}, #"календарь", {"дата"}, "дата_joined", JoinKind.LeftOuter), //присоединяем календарь
    expand_calendar = Table.ExpandTableColumn(join_calendar, "дата_joined", {"год", "месяц год"}, {"схема.год", "схема.месяц год"}),
    join_project = Table.NestedJoin(expand_calendar, {"проект_key"}, проект, {"проект_key"}, "проект_joined", JoinKind.LeftOuter), //присоединяем проект
    expand_project = Table.ExpandTableColumn(join_project, "проект_joined", {"проект", "подпроект"}, {"схема.проект", "схема.подпроект"}),
    join_subcontractor = Table.NestedJoin(expand_project, {"организация_key"}, организация, {"организация_key"}, "организация_joined", JoinKind.LeftOuter), //присоединяем организацию
    expand_subconractor = Table.ExpandTableColumn(join_subcontractor, "организация_joined", {"организация"}, {"схема.организация"}),
    join_kluchevie = Table.NestedJoin(expand_subconractor, {"ключевые_key"}, ключевые, {"ключевые_key"}, "ключевые_joined", JoinKind.LeftOuter),//присоединяем ключевые
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
    join_tipovie = Table.NestedJoin(expand_kluchevie, {"схема.типовые_key"}, #"типовые", {"типовые_key"}, "типовые_joined", JoinKind.LeftOuter), //присоединяем типовые
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
    add_refresh_date = fnAddRefreshDateTime(expand_tipovie, [column = "время обновления база"]), //добавлем время обновления
    select_final_cols = Table.SelectColumns( //выбираем столбцы
        add_refresh_date,
        {
            "дата",
            "схема.год",
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
            "имя листа",
            "время обновления база"
        }
    )
in
    select_final_cols