/* 
    цель:
        Добавляет к таблице столбцы, с помощью которых пользователь может группировать строки журнала.
        Что такое иерархия: смотри README
    аргументы:
        max_level - максимальный уровень иерархии
        hierarchy_col - имя столбца в котором задан уровень иерархии
        descr_col - имя столбца в котором содержится значение иерархии
 */
(source, max_level, hierarchy_col, descr_col) =>
    let
        // [
        NEW_HIERARCHY_NAMES = //список новых столбцов, в которые раскрываем иерархию
            List.Buffer(
                List.Transform(
                    {1..max_level},
                    each "ркц ур" & Text.From(_)
                )
            ),
        hierarchy_to_num = //преобразовываем тип данных столбца, который содержит номера уровеней
            Table.TransformColumnTypes( //в число
                source,
                {
                    hierarchy_col,
                    Int64.Type
                }
            ),
        //функция для извлечения иерархии
        //принцип следующий:
        //номер столбца в который записывается значение иерархии определяется по номеру уровня
        //в столбцы у которых уровень выше записываем null, чтобы иерархия протянулась с более высоких уровней 
        //в столбцы у которых уровень ниже записываем пустую строку, чтобы иерархия не протянулась с более низких уровней 
        fnGetHierarchy =
            (row) =>
                let
                    hierarchy_level = Record.Field(row, hierarchy_col), //значение уровня иерархии
                    hierarchy_header = Record.Field(row, descr_col), //значение иерархи
                    //модуль уровня иерархии, необходим для совместимостью со старой кодировкой журналов
                    hierarchy_level_abs = Number.Abs(hierarchy_level),
                    nulls = //для уровней выше генерируем null
                        List.Repeat(
                            {null},
                            hierarchy_level_abs - 1
                        ),
                    stoppers = //для уровней выше генерируем пустые строки
                        List.Repeat(
                            {""},
                            max_level - hierarchy_level_abs
                        ),
                    combine = nulls //объединяем иерархию и сгенерированные списки
                        & {
                            hierarchy_header
                        } & stoppers,
                    hierarchy_record = //создаем запись у которой в полях имена новых столбцов
                        Record.FromList( //а в значениях объединенный список с иерархией, null и пустыми строками
                            combine,
                            NEW_HIERARCHY_NAMES
                        )
                in
                    hierarchy_record,
        add_hierarchy = //добавлем столбец с записью
            Table.AddColumn(
                hierarchy_to_num,
                "_hierarchy",
                fnGetHierarchy
            ),
        replace_errors = //заменяем ошибки при извлечении иерархии на null
            Table.ReplaceErrorValues(
                add_hierarchy,
                {
                    {
                        "_hierarchy",
                        null
                    }
                }
            ),
        expand_hierarchy = //раскрываем иерархию в столбцы
            Table.ExpandRecordColumn(
                replace_errors,
                "_hierarchy",
                NEW_HIERARCHY_NAMES
            ),
        fill_down = //протягиваем иерархию
            Table.FillDown(
                expand_hierarchy,
                NEW_HIERARCHY_NAMES
            )
    // ]
    in
        fill_down