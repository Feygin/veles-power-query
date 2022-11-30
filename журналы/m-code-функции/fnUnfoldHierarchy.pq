/* 
    Цель: 
 */
(source, max_level, hierarchy_col, descr_col)=>
    let
        // [
        NEW_HIERARCHY_NAMES = 
            List.Buffer(
                List.Transform({1..max_level}, each "ркц ур" & Text.From(_))
            ),
        
        hierarchy_to_num = Table.TransformColumnTypes(source, {hierarchy_col, Int64.Type}),

        fnGetHierarchy = (row)=>
            let
                hierarchy_level = Record.Field(row, hierarchy_col),
                hierarchy_header = Record.Field(row, descr_col),
                hierarchy_level_abs = Number.Abs(hierarchy_level),
                nulls = List.Repeat({null}, hierarchy_level_abs - 1),
                stoppers = List.Repeat({""}, max_level - hierarchy_level_abs),
                combine = nulls & {hierarchy_header} & stoppers,
                hierarchy_record = Record.FromList(combine, NEW_HIERARCHY_NAMES)
            in
                hierarchy_record,

        add_hierarchy = Table.AddColumn(hierarchy_to_num, "_hierarchy", fnGetHierarchy ),
        replace_errors = Table.ReplaceErrorValues(add_hierarchy, {{"_hierarchy", null}}),
        expand_hierarchy = Table.ExpandRecordColumn(replace_errors, "_hierarchy", NEW_HIERARCHY_NAMES),
        fill_down = Table.FillDown(expand_hierarchy, NEW_HIERARCHY_NAMES)
        // ]
    in
        fill_down