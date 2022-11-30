/* 
    Цель: unpivot части журнала содержащего данные по периодам
 */
(source)=>
let
    // [
        SEPARATOR = "^",
        MULTIHEADER_ROWS = {"показатель", "дата", "идентификатор"},

        columns_to_unpivot = List.Select(Table.ColumnNames(source), each Text.Contains(_, SEPARATOR)),
        unpivot = Table.Unpivot(source, columns_to_unpivot, "аттрибут", "значение"),
        filter_nulls = Table.SelectRows(unpivot, each ([значение] <> 0) and ([значение] <> null) and ([значение] <> "")),
        split_multiheader = Table.SplitColumn(filter_nulls, "аттрибут", Splitter.SplitTextByDelimiter("^", QuoteStyle.Csv), MULTIHEADER_ROWS),
        pivot = Table.Pivot(split_multiheader, List.Distinct(split_multiheader[показатель]), "показатель", "значение"),
        extract_text_from_dup_attributes= Table.TransformColumns(pivot, {{"идентификатор", each Text.BeforeDelimiter(_, "_"), type text}})
    // ]
in
    extract_text_from_dup_attributes