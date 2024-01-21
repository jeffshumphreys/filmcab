# https://stackoverflow.com/questions/1184893/how-to-loop-datareader-and-create-datatable-in-powershell#1185081
$xlsFile = "C:\Temp\Data.xlsx"
$datatable | Export-OpenXmlSpreadSheet -OutputPath $xlsFile  -InitialRow 3