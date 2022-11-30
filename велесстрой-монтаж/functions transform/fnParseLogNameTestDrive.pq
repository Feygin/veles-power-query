let
    log_names = {
        "Журнал - 1 _ оРгаНиЗАЦИЯ _Проект_Подпроект_Дисциплина_РАБОЧИЙ_ 31.12.2022.xlsx",
        "Журнал-1_Организация_Проект_Подпроект_Дисциплина_РАБОЧИЙ ДАТА ТЕКСТ_декабрь 2022.xlsx",
        "Журнал-1_Организация_Проект_Подпроект_Дисциплина_НЕВЕРНАЯ ДАТА_декабрь год 2022.xlsx",
        "Журнал-1_Организация_Проект_Неверное кол-во_НЕВЕРНЫЙ ШАБЛОН.xlsx"
    },
    names_to_table = Table.FromColumns({log_names}, {"log_names"}),
    parse_names = Table.AddColumn(names_to_table, "log_names_parsed", each fnParseLogName([log_names])),
    expand_record = Table.ExpandRecordColumn(parse_names, "log_names_parsed", Record.FieldNames(parse_names{0}[log_names_parsed]))
in
    expand_record