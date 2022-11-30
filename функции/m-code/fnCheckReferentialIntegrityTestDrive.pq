let
    fact = Excel.CurrentWorkbook(){[Name="fnCheckReferentialIntegritySourceFact"]}[Content],
    dim = Excel.CurrentWorkbook(){[Name="fnCheckReferentialIntegritySourceDim"]}[Content],

    test_has_missing_no_context_no_agg = fnCheckReferentialIntegrity(
        [
            fact_table = fact,
            fact_key = "id",
            dim_table = dim,
            dim_key = "id"
            
        ]
    ),
    test_has_missing_with_context_and_agg = fnCheckReferentialIntegrity(
        [
            fact_table = fact,
            fact_key = "id",
            dim_table = dim,
            dim_key = "id",
            fact_context_columns = {"filename", "foldername"},
            fact_value_columns = {"val", "val1"}
        ]
    ),
    fact_no_missing = Table.SelectRows(fact, each ([id] <> null) and not (Text.Contains([id], "missing"))),
    test_no_missing = fnCheckReferentialIntegrity(
        [
            fact_table = fact_no_missing,
            fact_key = "id",
            dim_table = dim,
            dim_key = "id",
            fact_context_columns = {"filename", "foldername"},
            fact_value_columns = {"val", "val1"}
        ]
    )
in
    test_no_missing