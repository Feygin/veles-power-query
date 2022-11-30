let
    // source = Table.PromoteHeaders(Excel.CurrentWorkbook(){[Name="типовые_padding"]}[Content], [PromoteAllScalars=true])
    // ,
    source = 
        let
            data = fnGetTableFromFile(dimension_path, [kind = "Sheet", name = "типовые"]),
            promote_header = Table.PromoteHeaders(data, [PromoteAllScalars = true]),
            replace_false_values_from_google = Table.ReplaceValue(promote_header,"-",null,Replacer.ReplaceValue,{"типовые вед поз", "добавлено гувр"}),
            filter_nulls = Table.SelectRows(replace_false_values_from_google, each ([типовые наименование источник] <> null))
        in
            filter_nulls
in
    source