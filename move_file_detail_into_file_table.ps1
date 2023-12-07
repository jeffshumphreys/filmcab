<#
REM https://doc.qt.io/Qt-5/windows-deployment.html
REM worked. Added dlls to bin dir
windeployqt --debug --verbose 2 D:\qt_projects\build-filmcab-Desktop_Qt_6_5_3_MinGW_64_bit-Debug\debug
#>

D:\qt_projects\build-filmcab-Desktop_Qt_6_5_3_MinGW_64_bit-Debug\debug\filmcab.exe -f "scan_folders_and_pull_file_details_into_database" -d filmcab --showprogress
