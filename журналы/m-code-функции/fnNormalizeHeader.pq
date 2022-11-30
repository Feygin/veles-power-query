/* 
    Цель: определение базы к которой принадлежат столбцы (факт / контракт), нормализация заголовков
*/
(source)=>
    let
        CONTRACT_KEYWORD = "контракт^",
        FACT_KEYWORD = "факт^",
        FACT_EXCLUDE_KEYWORD = "^^факт исключить",
        HIERARCHY_KEYWORD =  "ркц ур",
        FILENAME = "имя файла",

        cols = Table.ColumnNames(source),
        to_table = Table.FromColumns({cols}, {"извлеченные столбцы"}),
        add_contract_marker = Table.AddColumn(
            to_table,
            "столбцы контракт",
            each 
                if Text.StartsWith([извлеченные столбцы], CONTRACT_KEYWORD) then
                    "v"
                else if Text.StartsWith([извлеченные столбцы], HIERARCHY_KEYWORD) then
                    "v"
                else if ([извлеченные столбцы] = FILENAME) then
                    "v"
                else 
                    null
        ),
        add_fact_marker = Table.AddColumn(
            add_contract_marker,
            "столбцы факт",
            each 
                if Text.StartsWith([извлеченные столбцы], FACT_KEYWORD) then
                    "v"
                else if Text.StartsWith([извлеченные столбцы], CONTRACT_KEYWORD) and not Text.EndsWith([извлеченные столбцы], FACT_EXCLUDE_KEYWORD) then
                    "v"
                else if Text.StartsWith([извлеченные столбцы], HIERARCHY_KEYWORD) then
                    "v"
                else if ([извлеченные столбцы] = FILENAME) then
                    "v"
                else 
                    null
        ),
        add_new_names = Table.AddColumn(
            add_fact_marker,
            "столбцы нормализованные",
            each
                if Text.StartsWith([извлеченные столбцы], FACT_KEYWORD) then
                    Text.AfterDelimiter([извлеченные столбцы], FACT_KEYWORD)
                else if Text.StartsWith([извлеченные столбцы], CONTRACT_KEYWORD) then
                    Text.BetweenDelimiters([извлеченные столбцы], "^", "^^")
                else 
                    [извлеченные столбцы]
        )
    in
        add_new_names