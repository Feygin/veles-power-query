let
    source = _expected_all_files,
    join_error_results = Table.NestedJoin(source, {"имя файла", "лист"}, #"_errors", {"имя файла", "лист"}, "_pipeline_errors", JoinKind.LeftOuter),
    expand_error_results = Table.ExpandTableColumn(join_error_results, "_pipeline_errors", {"статус"}, {"статус_err"}),
    join_successful_results = Table.NestedJoin(expand_error_results, {"имя файла", "лист"}, #"_successful", {"имя файла", "лист"}, "_pipeline_successful", JoinKind.LeftOuter),
    expand_successfull_result = Table.ExpandTableColumn(join_successful_results, "_pipeline_successful", {"статус"}, {"статус_successful"}),
    merge_results = Table.CombineColumns(expand_successfull_result,{"статус_err", "статус_successful"},Combiner.CombineTextByDelimiter("", QuoteStyle.None),"статус"),
    replace_nulls_with_missing_status = Table.ReplaceValue(merge_results,"","не найдено",Replacer.ReplaceValue,{"статус"})
in
    replace_nulls_with_missing_status