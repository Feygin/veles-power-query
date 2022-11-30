let
    source = #"_типовые_иерархия",
    select_needed_cols = 
        Table.SelectColumns(
            source,
            {
                "типовые наименование", "ед изм", 
                "типовые_key", "типовые вед поз", 
                "типовые уровень", "типовые путь"
            }
        ), //оставляем столбцы относящиеся к задаче
    
    //раскрываем путь типовых позиций
    select_cols = Table.SelectColumns(select_needed_cols, {"типовые путь", "типовые_key", "типовые уровень"}),
    parse_hierarchy_path = Table.AddColumn(select_cols, "типовые путь splitted", each Text.Split([типовые путь], "|"), type list),
    expand_hierarchy_path = Table.ExpandListColumn(parse_hierarchy_path, "типовые путь splitted"),
    join_leading = Table.NestedJoin(expand_hierarchy_path, {"типовые путь splitted"}, select_needed_cols, {"типовые_key"}, "типовые_joined"),
    get_leading = Table.ExpandTableColumn(join_leading, "типовые_joined", {"типовые вед поз"}),
    group_by_tipovie = Table.Group(get_leading, {"типовые_key"}, {"group", each _}),

    //определяем ведущую позицию для текущего уровня
    cur_lvl = Table.AddColumn(group_by_tipovie, "текущий уровень", each List.First([group][типовые уровень])), //текущий уровень
    cur_lvl_leading = Table.AddColumn(cur_lvl, "текущий уровень вед поз", each Record.FromList({"v"}, {"типовые ур" & Text.From([текущий уровень]) & " вед поз"}) ), //текущий уровень всегда является ведущим

    //определяем ведущие позиции для остальных уровней
    //ведущая позиция в таблице подчиняется следующей логике ->
    //вед поз задает условие, что объем с этого уровня попадает на родительский уровень 
    add_parent_lvls_descr = Table.AddColumn(
        cur_lvl_leading, 
        "родительские уровни", 
        each
            Table.AddColumn( //превращаем номер уровня в название
                Table.AddIndexColumn( //добавляем номер уровня к которому относится вед поз
                    //первая строка группы относится к 0 уровню, для 0 уровня логика ведущая позиции не определена
                    //так как не существует уровня -1, поэтому убираем ее
                    Table.Skip([group],1), 
                    "номер уровня", 
                    0
                ),
                "типовые уровень наименование",
                each "типовые ур" & Text.From([номер уровня]) & " вед поз"
            )
    ),
    add_parrent_lvls_leading = Table.AddColumn(
        add_parent_lvls_descr,
        "родительские уровни вед поз приведение",
        each
            let
                // [
                    leading = [родительские уровни][типовые вед поз],
                    reversed = List.Reverse(leading), //инвертируем список, чтобы определить первую позицию где прекращается цепочка ведущих позиций
                    position_where_leading_stops = List.PositionOf(reversed, null), //определяем позицию где цепочка ведущих позиций прекращается
                    //если цепочка не прекращается, считаем, что она заканчивается в конце списка
                    position_where_leading_stops_adj = if position_where_leading_stops = -1 then List.Count(leading) else position_where_leading_stops, 
                    
                    //заполняем все родительские уровни после остановки цепочки значениями null
                    repeat_nulls_for_all_parents = List.Repeat({null}, List.Count(leading) - position_where_leading_stops_adj), 
                    leading_values = List.Repeat({"v"}, position_where_leading_stops_adj), //заполняем все позиции до остановки цепочки ведущими позициями
                    combine = repeat_nulls_for_all_parents & leading_values, //объединяем списки
                    
                    group_data = [родительские уровни],
                    data_to_columns = Table.ToColumns(group_data), //представляем таблицу с группой в виде списков столбцов
                    add_leading_data = data_to_columns & {combine}, //добавляем список с приведенными ведущими позициями
                    new_col_names = Table.ColumnNames(group_data) & {"типовые вед поз приведенная"},
                    to_table = Table.FromColumns(add_leading_data, new_col_names)
                // ]
            in
                to_table
    ),
    parrent_lvls_leading_to_record = Table.AddColumn(
        add_parrent_lvls_leading,
        "родительские уровни вед поз",
        each 
            Record.FromTable( //создаем запись с ведущими позициями для всех уровней
                Table.RenameColumns(
                    Table.SelectColumns([родительские уровни вед поз приведение], {"типовые уровень наименование", "типовые вед поз приведенная"}), //оставляем навание уровней и список вед позиций
                    {
                        {"типовые уровень наименование", "Name"}, //переиновываем, чтобы трансформировать в запись
                        {"типовые вед поз приведенная", "Value"}
                    }
                )
            )
    ),

    //объединяем записи с вед поз
    combine_records = Table.AddColumn(parrent_lvls_leading_to_record, "ведущие позиции", each [родительские уровни вед поз] & [текущий уровень вед поз]),

    //раскрываем записи с ведущими позициями
    expand_leading = Table.ExpandRecordColumn(
        combine_records, 
        "ведущие позиции", 
        {"типовые ур0 вед поз", "типовые ур1 вед поз", "типовые ур2 вед поз", "типовые ур3 вед поз", "типовые ур4 вед поз"}
    ),
    select_resulting_cols = Table.SelectColumns(
        expand_leading, 
        {
            "типовые_key", "текущий уровень", 
            "типовые ур0 вед поз", "типовые ур1 вед поз",
            "типовые ур2 вед поз", "типовые ур3 вед поз",
            "типовые ур4 вед поз"
        }
    )
in
    select_resulting_cols