/* 
    объединяем преобразованные таблицы с ключевыми объемами,
    формируем ключи и обогащаем данными из схема
 */
let
    source = #"_трансформируем_данные", //ссылка на предыдущий шаг
    select_cols = Table.SelectColumns(source, {"имя файла", "лист", "Unpivot"}), //оставляем поля с данными и их метаданными
    filter = Table.SelectRows(select_cols, each [лист] = "ключевые объемы"), //оставляем строки с ключевыми объемами
    remove_sheet = Table.RemoveColumns(filter, {"лист"}), //удаляем поле с именем листа
    remove_rows_with_err = Table.RemoveRowsWithErrors(remove_sheet), //удаляем строки с ошибками
    expand_cols = Table.ExpandTableColumn( //объединяем содержимое
        remove_rows_with_err, 
        "Unpivot", 
        {"дата", "проект", "подпроект", "организация", "ключевые", "ед изм", "Value"}
    ),
    rename_columns = Table.RenameColumns(expand_cols,{{"Value", "объем"}}), //переименовываем поле с объемом

    //формируем ключи
    dup_project = Table.DuplicateColumn(rename_columns, "проект", "проект_dup"), //дублируем поля по которым создаем ключ
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
    change_dtypes = Table.TransformColumnTypes( //изменяем типы данных
        normalize_subproject_key, 
        {
            {"дата", type date},
            {"объем", type number}
        }
    ),
    //обогащаем данные значениями из схемы
    join_calendar = Table.NestedJoin(change_dtypes, {"дата"}, #"календарь", {"дата"}, "дата_joined", JoinKind.LeftOuter), //присоединяем календарь
    expand_calendar = Table.ExpandTableColumn(join_calendar, "дата_joined", {"месяц год"}, {"схема.месяц год"}),
    join_project = Table.NestedJoin(expand_calendar, {"проект_key"}, #"проект", {"проект_key"}, "проект_joined", JoinKind.LeftOuter), //присоединяем проект
    expand_project = Table.ExpandTableColumn(join_project, "проект_joined", {"проект", "подпроект"}, {"схема.проект", "схема.подпроект"}),
    join_subcontractor = Table.NestedJoin(expand_project, {"организация_key"}, #"организация", {"организация_key"}, "организация_joined", JoinKind.LeftOuter), //присоединяем организацию
    expand_subconractor = Table.ExpandTableColumn(join_subcontractor, "организация_joined", {"организация"}, {"схема.организация"}), 
    join_kluchevie = Table.NestedJoin(expand_subconractor, {"ключевые_key"}, #"ключевые", {"ключевые_key"}, "ключевые_joined", JoinKind.LeftOuter), //присоединяем ключевые
    expand_kluchecie = Table.ExpandTableColumn(
        join_kluchevie, 
        "ключевые_joined", 
        {
            "ключевые ур0 наименование с ед изм", 
            "ключевые ур0 вед поз", 
            "ключевые ур1 наименование с ед изм", 
            "ключевые ур1 вед поз",
            "типовые_key", 
            "типовые вед поз"
        }, 
        {
            "схема.ключевые ур0 наименование с ед изм", 
            "схема.ключевые ур0 вед поз", 
            "схема.ключевые ур1 наименование с ед изм", 
            "схема.ключевые ур1 вед поз",
            "схема.типовые_key", 
            "схема.типовые вед поз"
        }
    ),
    join_tipovie = Table.NestedJoin(expand_kluchecie, {"схема.типовые_key"}, #"типовые", {"типовые_key"}, "типовые_joined", JoinKind.LeftOuter), //присоединяем типовые
    expand_tipovie = Table.ExpandTableColumn(
        join_tipovie, 
        "типовые_joined", 
        {
            "типовые наименование с ед изм",
            "типовые ур0 наименование с ед изм", 
            "типовые ур0 вед поз", 
            "типовые ур1 наименование с ед изм", 
            "типовые ур1 вед поз",
            "типовые ур2 наименование с ед изм", 
            "типовые ур2 вед поз"
        }, 
        {
            "схема.типовые наименование с ед изм",
            "схема.типовые ур0 наименование с ед изм", 
            "схема.типовые ур0 вед поз", 
            "схема.типовые ур1 наименование с ед изм", 
            "схема.типовые ур1 вед поз",
            "схема.типовые ур2 наименование с ед изм", 
            "схема.типовые ур2 вед поз"
        }
    ),
    add_refresh_date = fnAddRefreshDateTime(expand_tipovie, [column = "время обновления база"]), //добавлем столбец с временем обновления
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
            "схема.ключевые ур0 наименование с ед изм", 
            "схема.ключевые ур0 вед поз", 
            "схема.ключевые ур1 наименование с ед изм", 
            "схема.ключевые ур1 вед поз",
            "схема.типовые_key", 
            "схема.типовые наименование с ед изм",
            "схема.типовые ур0 наименование с ед изм", 
            "схема.типовые ур0 вед поз", 
            "схема.типовые ур1 наименование с ед изм", 
            "схема.типовые ур1 вед поз",
            "схема.типовые ур2 наименование с ед изм", 
            "схема.типовые ур2 вед поз",
            "объем",
            "имя файла",
            "время обновления база"
        }
    )
in
    select_final_cols