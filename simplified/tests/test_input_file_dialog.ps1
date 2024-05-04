Function CustomInputBox([string] $title, [string] $message, [string] $defaultText)
{
$inputObject = new-object -comobject MSScriptControl.ScriptControl
$inputObject.language = "vbscript" 
$inputObject.addcode("function getInput() getInput = inputbox(`"$message`",`"$title`" , `"$defaultText`") end function" ) 
$_userInput = $inputObject.eval("getInput") 

return $_userInput
}
$x = CustomInputBox "User Name" "enter your name"