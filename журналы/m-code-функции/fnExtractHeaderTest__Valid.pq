let
    source_valid = Excel.CurrentWorkbook(){[Name="customHeaderValid"]}[Content],
    extract_header_valid = fnExtractHeader(source_valid)
in
    extract_header_valid