/* 
    объединяем преобразованные таблицы с техникой,
    трансформируем аттрибуты ед изм (ч.ч., часы) в столбцы,
    формируем ключи и обогащаем данными из схема
 */
let
    source = #"_трансформируем_данные", //ссылка на предыдущий шаг
    select_cols = Table.SelectColumns(source, {"имя файла", "лист", "Unpivot"}), //оставляем поля с данными и их метаданными
    filter = Table.SelectRows(select_cols, each [лист] = "тех.ресурсы"), //оставляем строки с техническими ресурсами
    rename_sheet_attr = Table.RenameColumns(filter, {{"лист", "имя листа"}}), //переименовываем поле с именем листа
    remove_rows_with_err = Table.RemoveRowsWithErrors(rename_sheet_attr), //удаляем строки с ошибками
    expand_cols = Table.ExpandTableColumn( //объединяем содержимое
        remove_rows_with_err, 
        "Unpivot", 
        {"дата", "проект", "подпроект", "вид техники", "ед изм", "Value"}
    ),

    //pivot
    pivot = Table.Pivot(expand_cols, List.Distinct(expand_cols[#"ед изм"]), "ед изм", "Value", List.Sum), //пивот по столбцу единица измерения
    rename_cols = Table.RenameColumns(pivot,{{"факт (м.ч.)", "часы"}, {"факт (ед)", "техника"}}), //переименовываем столбцы со значением часов
    remove_delta = Table.RemoveColumns(rename_cols,{"Δ", "план"}, MissingField.Ignore), //удаляем ненужные показатели 

  
    //формируем ключи, их используем для объединения данных со схемой
    dup_project = Table.DuplicateColumn(remove_delta, "проект", "проект_dup"), //дублируем поля по которым создаем ключ
    dup_subproject = Table.DuplicateColumn(dup_project, "подпроект", "подпроект_dup"),
    dup_machinery = Table.DuplicateColumn(dup_subproject, "вид техники", "наименование техники_key"),
    clean_dups = Table.TransformColumns( //нормализуем продублированные поля
        dup_machinery,
        {
            {"проект_dup", each Text.Trim(Text.Clean(Text.Lower(_))), type text}, 
            {"подпроект_dup", each Text.Trim(Text.Clean(Text.Lower(_))), type text},
            {"наименование техники_key", each Text.Trim(Text.Clean(Text.Lower(_))), type text}
    }),
    create_project_key = Table.CombineColumns(clean_dups,{"проект_dup", "подпроект_dup"},Combiner.CombineTextByDelimiter("_", QuoteStyle.None),"проект_key"), //создаем композитный ключ для проекта

    //заменяем . на , в числовых полях и изменяем тип данных
    replace_dots_in_nums = fnReplaceSymbols( //заменяем "." на "," в числовых столбцах, чтобы при преобразовании
        create_project_key, //типа данных не появились ошибки
        [columns = {"техника", "часы"}, replacement = {{".", ","}}] 
    ),
    change_dtype = Table.TransformColumnTypes( //изменяем типы данных
        replace_dots_in_nums, 
        {
            {"дата", type date},
            {"техника", type number},
            {"часы", type number}
        }
    ),

    //объединяем данные с таблицами из схемы
    join_calendar = Table.NestedJoin(change_dtype, {"дата"}, #"календарь", {"дата"}, "дата_joined", JoinKind.LeftOuter), //присоединяем календарь
    expand_calendar = Table.ExpandTableColumn(join_calendar, "дата_joined", {"год", "месяц год"}, {"схема.год", "схема.месяц год"}),
    join_project = Table.NestedJoin(expand_calendar, {"проект_key"}, #"проект", {"проект_key"}, "проект_joined", JoinKind.LeftOuter), //присоединяем проект
    expand_project = Table.ExpandTableColumn(join_project, "проект_joined", {"проект", "подпроект"}, {"схема.проект", "схема.подпроект"}),
    join_machinery = Table.NestedJoin(expand_project, {"наименование техники_key"}, #"техника", {"наименование техники_key"}, "техника_joined", JoinKind.LeftOuter), //присоединяем наименование техники
    expand_machinery = Table.ExpandTableColumn(join_machinery, "техника_joined", {"наименование техники", "группа техники"}, {"схема.наименование техники", "схема.группа техники"}),

    add_refresh_date = fnAddRefreshDateTime(expand_machinery, [column = "время обновления база"]), //добавлем время обновления
  
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
            "вид техники",
            "наименование техники_key",
            "схема.наименование техники",
            "схема.группа техники",
            "техника",
            "часы",
            "имя файла",
            "имя листа",
            "время обновления база"
        }
    )
in
    select_final_cols