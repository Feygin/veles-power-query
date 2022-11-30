/* 
    Функция для создания вложенных записей из таблицы с иерархией 
*/

(source as table, _parameter as record) =>
    let
        // [
        path = Record.Field(_parameter, "path"),
        value = Record.Field(_parameter, "value"),
        squeeze = Record.FieldOrDefault(_parameter, "squeeze", false),

        fnGetListFromGroup =
            (columns)=>
                (group)=>
                    List.Buffer(Table.Column(group, columns)), //с буфером пошустрей работает
        fnSquezee =         
            (columns)=>
                (group)=>
                    List.First(List.Buffer(Table.Column(group, columns))),
        fnGroupTransformation = if squeeze = true then fnSquezee else fnGetListFromGroup,

        source_buffer = Table.Buffer(source),

        initial_group = Table.Group(source_buffer, path, {"Value", fnGroupTransformation(value)}),
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

        /* решение через recursion
            ,
            fnProcessHierarchyRecursion = 
                (source as table, path)=>
                    let
                        last_path_item = List.Last(path),
                        pop_value = List.RemoveLastN(path),
                        create_record = Table.Group(source_buffer, pop_value, {"Value", fnCreateRecord(last_path_item)}),
                        result = if List.IsEmpty(pop_value) then create_record else @fnProcessHierarchyRecursion(create_record, pop_value)
                    in
                        result,
            get_hierarchy_recursion = fnProcessHierarchyRecursion(initial_group, path),
            get_first_level_recursion = get_hierarchy_recursion{0}[Value] 
        */
        // ]
    in
        get_first_level