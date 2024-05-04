Function Test-ValidateScriptThrow{
    param(
        [ValidateScript( { 
            ![String]::IsNullOrWhiteSpace($_) -or {throw 'Your string is null or contains whitespace'}]{}
         )]
    )
}