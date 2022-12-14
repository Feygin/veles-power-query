/* 
    содержимое файла схема
 */
let
    source = Excel.Workbook(File.Contents("C:\Users\FeyginAS\Desktop\veles-power-quey\модель\тест\схема.xlsx"), null, true), //содержимое файла
    select_attribute_columns = //оставляем нужные аттрибуты
        Table.SelectColumns(
            source,
            {
                "Name",
                "Kind", 
                "Item", 
                "Data" 
            }
        ),
    filter_tables = Table.SelectRows(select_attribute_columns, each [Kind] = "Table") //оставляем таблицы
in
    filter_tables