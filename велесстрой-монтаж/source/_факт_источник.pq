let
    source = Excel.Workbook(File.Contents(#"log_db_path"), null, true),
    data = source{[Item="факт",Kind="Table"]}[Data],
    select_cols = 
        if (try data)[HasError] = true then
            error Error.Record("Не удается найти таблицу факт в " & #"log_db_path")
        else
            Table.SelectColumns(data, #"столбцы_факт_исх", MissingField.UseNull),
    //извлекаем аттрибуты из названия файла
    extract_file_attr = Table.AddColumn(select_cols, "имя файла аттрибуты", each fnParseLogName([имя файла])),
    expand_file_attr = Table.ExpandRecordColumn(
        extract_file_attr, 
        "имя файла аттрибуты", 
        {"is_valid_template", "log_id", "project_name", "area", "subcontractor"}, 
        {"журнал.проверка имени", "журнал номер", "журнал.проект", "журнал.подпроект", "журнал.организация"}
    ),
    coalesce_attr = 
        let
            coalesce_project = Table.ReplaceValue(expand_file_attr, each [проект], each if ([журнал.проверка имени] = true) and ([проект] = null) then [журнал.проект] else [проект], Replacer.ReplaceValue, {"проект"}),
            coalesce_subproject = Table.ReplaceValue(coalesce_project, each [подпроект], each if ([журнал.проверка имени] = true) and ([подпроект] = null) then [журнал.подпроект] else [подпроект], Replacer.ReplaceValue, {"подпроект"}),
            coalesce_subcontracor = Table.ReplaceValue(coalesce_subproject, each [организация], each if ([журнал.проверка имени] = true) and ([организация] = null) then [журнал.организация] else [организация], Replacer.ReplaceValue, {"организация"}),
            remove_expaned_cols = Table.RemoveColumns(coalesce_subcontracor,{"журнал.проверка имени", "журнал.проект", "журнал.подпроект", "журнал.организация"})
        in
            remove_expaned_cols
in
    coalesce_attr