/* 
    Функция для создания вложенных записей из таблицы с иерархией 
*/

(source as table, _parameter as record) =>
    let
        // [
        path = Record.Field(_parameter, "path"),
        value = Record.Field(_parameter, "value"), //list

        fnGetTableFromGroup =
            (columns)=>
                (group)=>
                    Table.Buffer(Table.SelectColumns(group, value)),

        source_buffer = Table.Buffer(source),

        initial_group = Table.Group(source_buffer, path, {"Value", fnGetTableFromGroup(value)}),
        fnCreateRecord = 
            (last_path_item)=>
                (group)=>
                    let
                        rename_cols = Table.RenameColumns(group, {last_path_item, "Name"}),
                        select_cols = Table.SelectColumns(rename_cols, {"Name", "Value"}),
                        get_record = Record.FromTable(select_cols)
                    in
                        get_record,
        generate_hierarchy =
            List.Generate(
                ()=>
                    [
                        seed = initial_group,
                        last_path_item = List.Last(path),
                        group_path = List.RemoveLastN(path),
                        counter = 0
                    ],
                each [counter] <= List.Count(path),
                each 
                    [
                        seed = Table.Group([seed], [group_path], {"Value", fnCreateRecord([last_path_item])}),
                        last_path_item = List.Last([group_path]),
                        group_path = List.RemoveLastN([group_path]),
                        counter = [counter] + 1
                    ],
                each [seed]
            ),
        get_hierarchy = List.Last(generate_hierarchy),
        get_first_level = get_hierarchy{0}[Value]
        // ]
    in
        get_first_level