let
    source = #"_join_schema",
    filter_out_1k1n = Table.SelectRows(source, 
        each ([классификатор_key] <> "1к") and ([классификатор_key] <> "1н")
    )
in
    filter_out_1k1n