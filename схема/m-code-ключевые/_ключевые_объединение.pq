let
    source_hierarchy = #"_ключевые_иерархия",
    source_leading = #"_ключевые_ведущие",

    //присоединяем ведущие позиции
    join = Table.NestedJoin(source_hierarchy, "ключевые наименование с ед изм", source_leading, "ключевые наименование с ед изм", "_joined", JoinKind.LeftOuter),
    expand_leading = Table.ExpandTableColumn(join, "_joined", {"ключевые ур0 вед поз", "ключевые ур1 вед поз"})
in
    expand_leading