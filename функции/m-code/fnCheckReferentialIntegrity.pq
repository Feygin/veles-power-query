/* 
    Функция для проверки referential integrity между fact и dimension table
 */
(
    _parameter as record
)=>
let
    // [
    fact_table = Record.Field(_parameter, "fact_table"),
    fact_key = Record.Field(_parameter, "fact_key"),
    dim_table = Record.Field(_parameter, "dim_table"),
    dim_key = Record.Field(_parameter, "dim_key"),
    fact_context_columns = Record.FieldOrDefault(_parameter, "fact_context_columns", {}),
    fact_value_columns = Record.FieldOrDefault(_parameter, "fact_value_columns", {}),

    missing_data = Table.NestedJoin(fact_table, fact_key, dim_table, dim_key, "left_join", JoinKind.LeftAnti),
    group_by_columns = {fact_key } & fact_context_columns,
    fnGroupAgg =
        (column_name)=>
            (group)=>
                List.Sum(Table.Column(group, column_name)),
    fnGroupTransformGenerator =
        (transformation)=>
            (column_name)=>
                {column_name, transformation(column_name), type number},
    group_aggs = List.Transform(fact_value_columns, fnGroupTransformGenerator(fnGroupAgg)),
    group_missing_data = Table.Group(missing_data, group_by_columns, group_aggs)
    // ]
in  
    group_missing_data