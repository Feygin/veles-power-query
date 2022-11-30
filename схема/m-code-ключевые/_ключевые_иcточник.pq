let
    // source = Table.PromoteHeaders(Excel.CurrentWorkbook(){[Name="ключевые_padding"]}[Content], [PromoteAllScalars=true])
    source = 
        let
            data = fnGetTableFromFile(dimension_path, [kind = "Sheet", name = "ключевые"]),
            promote_header = Table.PromoteHeaders(data, [PromoteAllScalars = true]),
            replace_false_values_from_google = Table.ReplaceValue(promote_header,"-",null,Replacer.ReplaceValue,{"ключевые вед поз", "типовые вед поз"}),
            filter_nulls = Table.SelectRows(replace_false_values_from_google, each ([ключевые наименование источник] <> null))
        in
            filter_nulls
in
    source