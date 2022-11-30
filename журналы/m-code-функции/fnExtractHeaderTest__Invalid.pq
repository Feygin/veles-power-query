let
    source_invalid = Excel.CurrentWorkbook(){[Name="customHeaderInvalid"]}[Content],
    extract_header_invalid = fnExtractHeader(source_invalid),
    err = (try extract_header_invalid)[Error]
in
    err