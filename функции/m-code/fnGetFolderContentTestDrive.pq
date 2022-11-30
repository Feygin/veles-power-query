let
    test_exclude_subfolders = 
        fnGetFolderContent(
            #"current_folder" & "fnGetFolderContentTestDrive",
            [
                exclude_subfolders = true
            ]
        ),
    test_dont_exclude_subfolders = 
        fnGetFolderContent(
            #"current_folder" & "fnGetFolderContentTestDrive",
            [
                exclude_subfolders = false
            ]
        )
in
    test_dont_exclude_subfolders