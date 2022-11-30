let
    source = Excel.CurrentWorkbook(){[Name="fnCreateRecordHierarchySource"]}[Content],
    test_full_path = 
        fnCreateRecordHierarchy(
            source,
            [
                path = {"lvl0", "lvl1", "lvl2", "lvl3"},
                value = "val"
            ]
        ),
    full_path_expand_data = 
        [
            lvl0 = test_full_path,
            lvl1 = lvl0[a],
            lvl2 = lvl1[aa],
            lvl3 = lvl2[aaa],
            val = lvl3[aaaa]
        ],
    full_path_with_nulls_data = 
        [
            lvl0 = test_full_path,
            missing_path = lvl0[path_with_nulls]
        ],
    test_full_path_squeeze = 
        fnCreateRecordHierarchy(
            source,
            [
                path = {"lvl0", "lvl1", "lvl2", "lvl3"},
                value = "val",
                squeeze = true
            ]
        ),
    full_path_squeeze_data = 
        [
            lvl0 = test_full_path_squeeze,
            lvl1 = lvl0[a],
            lvl2 = lvl1[aa],
            lvl3 = lvl2[aaa],
            val = lvl3[aaaa]
        ],
    test_partly_hierarhy = 
        fnCreateRecordHierarchy(
            source,
            [
                path = {"lvl0", "lvl1"},
                value = "val"
            ]
        ),
    partly_hierarchy_data = 
        [
            lvl0 = test_partly_hierarhy,
            lvl1 = lvl0[a],
            val = lvl1[aa]
        ]
in
    partly_hierarchy_data