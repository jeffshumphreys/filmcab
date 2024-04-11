
Function Least([array]$things) {
    return ($things|Measure -Minimum).Minimum
}                                            

Function Greatest([array]$things) {
    return ($things|Measure -Maximum).Maximum
}                                            

Function Left([string]$val, [int32]$howManyChars = 1) {
    if ([String]::IsNullOrEmpty($val)) { 
        # Made up rule: Empty doesn't have a Leftmost character. $null should break the caller.  Returning an empty string as "leftmost character" is a fudge, and causes problems.
        return $null
    }               
    $actualLengthWeWillGet = Least $howManyChars  $val.Length
    return $val.Substring(0,$actualLengthWeWillGet)
}

Function Right([string]$val, [int32]$howManyChars = 1) {
    if ([String]::IsNullOrEmpty($val)) { 
        return $null
    }               
    $actualLengthWeWillGet = Least $howManyChars  $val.Length
    
    return $val.Substring($val.Length - $actualLengthWeWillGet)           
}

Function Starts-With($str, $startswith) {
    throw [System.NotImplementedException]
}   

Function Ends-With($str, $startswith) {
    throw [System.NotImplementedException]
}   

Function NullIf([string]$val, [string]$ifthis = '') {
    if ($null -eq $val -or $val.Trim() -eq $ifthis) {return $null}
    return $val
}                        

<#
.SYNOPSIS
Generate MD5 hash from string 

.DESCRIPTION
Impossible to remember

.PARAMETER s
Parameter description

.EXAMPLE
An example

.NOTES
Forgot where I was going use it?
#>
$md5provider = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
$utf8provider = New-Object -TypeName System.Text.UTF8Encoding

Function Hash-String($s) {
    return [System.BitConverter]::ToString($md5provider.ComputeHash($utf8provider.GetBytes($s)))    
}
<#
.SYNOPSIS
Return the best readable string for a SID DatabaseColumnValue.

.DESCRIPTION
Hack reductive way to get annoying sid strings to something readable.  But, to keep the call simple, if a user id or name is passed in and we can't convert it to a name, it just returns that string.  Making life easier, one day at a time.


.PARAMETER sidString
Either a sid, or a user's login id, machine id, etc.

.EXAMPLE
An example

.NOTES
This function is necessary since an unrecognized sid throws an error.
#>
Function Convert-SidToUser {
    param($sidString)
    try {
        $sid = New-Object System.Security.Principal.SecurityIdentifier($sidString)
        $user = $sid.Translate([System.Security.Principal.NTAccount])
        $user.Value
    } catch {
        return $sidString
    }
}

# Function Convert-ByteArrayToHexString ([byte[]] $bytearray) {
#     if ($null -eq $bytearray) {return $null}
#     return @($bytearray|Format-Hex|Select ascii).Ascii -join ''
# }
  
Function Convert-HexStringToByteArray {
    ################################################################
    #.Synopsis
    # Convert a string of hex data into a System.Byte[] array. An
    # array is always returned, even if it contains only one byte.
    #.Parameter String
    # A string containing hex data in any of a variety of formats,
    # including strings like the following, with or without extra
    # tabs, spaces, quotes or other non-hex characters:
    # 0x41,0x42,0x43,0x44
    # \x41\x42\x43\x44
    # 41-42-43-44
    # 41424344
    # The string can be piped into the function too.
    ################################################################
    [CmdletBinding()]
    Param ( [Parameter(Mandatory = $True, ValueFromPipeline = $True)] [String] $String )
    
    #Clean out whitespaces and any other non-hex crud.
    $String = $String.ToLower() -replace '[^a-f0-9\\,x\-\:]',"
    
    #Try to put into canonical colon-delimited format.
    $String = $String -replace '0x|\x|\-|,',':'
    
    #Remove beginning and ending colons, and other detritus.
    $String = $String -replace '^:+|:+$|x|\',"
    
    #Maybe there's nothing left over to convert...
    if ($String.Length -eq 0) { ,@() ; return }
    
    #Split string with or without colon delimiters.
    if ($String.Length -eq 1)
    { ,@([System.Convert]::ToByte($String,16)) }
    elseif (($String.Length % 2 -eq 0) -and ($String.IndexOf(":") -eq -1))
    { ,@($String -split '([a-f0-9]{2})' | foreach-object { if ($_) {[System.Convert]::ToByte($_,16)}}) }
    elseif ($String.IndexOf(":") -ne -1)
    { ,@($String -split ':+' | foreach-object {[System.Convert]::ToByte($_,16)}) }
    else
    { ,@() }
    #The strange ",@(...)" syntax is needed to force the output into an
    #array even if there is only one element in the output (or none).
}

<#
.SYNOPSIS
Converts a time duration to a more readable form

.DESCRIPTION
I always like to do this.  I want to see "1 Day" vs. "300000 Seconds"

.PARAMETER ob
The timer hopefully started earlier, perhaps at the top of the _dot_include_standard_header?

.EXAMPLE
An example

.NOTES
#TODO: Switch to humanizer?
#>    
Function Format-Humanize([Diagnostics.Stopwatch]$ob) {
    [timespan]$elapsed = $ob.Elapsed
    
    if ($elapsed.TotalDays -ge 1) {
            Format-Plural 'Day' $($elapsed.TotalDays) -includeCount
    }
    elseif ($elapsed.TotalHours -ge 1) {
        Format-Plural 'Hour' $($elapsed.TotalHours) -includeCount
    }
    elseif ($elapsed.TotalMinutes -ge 1) {
        Format-Plural 'Minute' $($elapsed.TotalMinutes) -includeCount
    }
    elseif ($elapsed.TotalSeconds -ge 1) {
        Format-Plural 'Second' $($elapsed.TotalSeconds) -includeCount
    }
    elseif ($elapsed.TotalMilliseconds -ge 1) {
        Format-Plural 'Millisecond' $($elapsed.TotalMilliseconds) -includeCount
    }
    elseif ($elapsed.TotalMicroseconds -ge 1) {
        Format-Plural 'Microsecond' $($elapsed.TotalMicroseconds) -includeCount
    }
    elseif ($elapsed.Ticks-gt 0) {
        Format-Plural 'Tick' $($elapsed.Ticks) -includeCount
    }
}
<#
.SYNOPSIS
Use in parameter [ValidateScript] call.  Only way I can find to fully document and test for the possibilities.

.DESCRIPTION
Trap these problems as early as possible, and get good error messages about what happened.

.PARAMETER s
The string we're testing.

.PARAMETER varname
The name of the parameter testing for documentation only.

.EXAMPLE
 [CmdletBinding()]
    param(           
        [Parameter(Position=0,Mandatory=$true)][ValidateScript({Assert-MeaningfulString $_ 'sql'})]        [string] $sql
    )

.NOTES
General notes
#>
<#
.SYNOPSIS
Humanize labels for numbers in output to humans.

.DESCRIPTION
Long description

.PARAMETER singularLabel
Parameter description

.PARAMETER number
Parameter description

.PARAMETER pluralLabel
Parameter description

.EXAMPLE
Write-AllPlaces "How many genre directories were found:          " $(Format-Plural 'Folder' $howManyGenreFolders -includeCount) 

.NOTES
General notes
#>
Function Format-Plural ([string]$singularLabel, [Int64]$number, [string]$pluralLabel = $null, [switch]$includeCount, [string]$variableName = $null) {
    $ct = ""

    if ($null -ne $variableName -and -not [string]::IsNullOrWhiteSpace($variableName)) {
        
        $ct+= $variableName.Humanize() + ": "
        $number = Get-Variable -Name $variableName -Scope Global -Value
        $includeCount = $true
    }


    if ($includeCount) {
        $ct+= $number.ToString() + " "
    }   

    if ($number -eq 1) {return ($ct + $singularLabel)}
    If ([String]::IsNullOrEmpty($pluralLabel)) {
        $LastCharacter = Right $singularLabel
        $Last2Characters = Right $singularLabel 2
        $SecondLastCharacter = Left $Last2Characters # Concise. Dont repit yourself.

        $Irregulars     = @{Man = 'Men'; Foot='Feet';Mouse='Mice';Person='People';Child='Children';'Goose'='Geese';Ox='Oxen';Woman='Women';Genus='Genera';Index='Indices';Datum='Data'}
        $NonCount= @('Moose', 'Fish', 'Species', 'Deer', 'Aircraft', 'Series', 'Salmon', 'Trout', 'Swine', 'Sheep')
        $OnlyS = @('photo', 'halo', 'piano')                                                                                                                
        $ExceptionsToFE = @('chef', 'roof')      
           
        if ($singularLabel -in $NonCount) {
            $plurallabel = $singularLabel 
        }                                                                        
        elseif ($singularLabel -in $Irregulars.Keys) {
            $plurallabel = $Irregulars[$singularLabel]
        }
        elseif ($singularLabel -in $OnlyS -or $singularLabel -in $ExceptionsToFE) {
            $plurallabel = $singularLabel + 's'
        }
        elseif ($LastCharacter -in @('s', 'ss', 'ch', 'x', 'sh', 'o', 'z') -or $Last2Characters -in @('s', 'ss', 'ch', 'x', 'sh', 'o', 'z')) { 
            $pluralLabel = $singularLabel + 'es'
        }  
        elseif ($Last2Characters -in @('f', 'fe')) { 
            $pluralLabel = $singularLabel.TrimEnd($Last2Characters) + 'ves' # Wife => Wives
        }  
        elseif ($LastCharacter -in @('f', 'fe')) { 
            $pluralLabel = $singularLabel.TrimEnd($LastCharacter) + 'ves'   # Calf => Calves
        }  
        elseif ($Last2Characters -in @('us')) {  
            $pluralLabel = $singularLabel.TrimEnd($Last2Characters) + 'i'   # Cactus => Cacti
        }  
        elseif ($Last2Characters -in @('is')) {  
            $pluralLabel = $singularLabel.TrimEnd($Last2Characters) + 'es'   # Analysis => analyses
        }  
        elseif ($Last2Characters -in @('on')) {  
            $pluralLabel = $singularLabel.TrimEnd($Last2Characters) + 'a'   # Phenomenon => Phenomena
        }  
        elseif ($LastCharacter -in @('y') -and $SecondLastCharacter -notin @('a','e','i','o','u')) { 
            $pluralLabel = $singularLabel.TrimEnd($LastCharacter) + 'ies' # City => Cities
        }  
        else {
            $pluralLabel = $singularLabel + 's'                             # Cat => Cats
        }
    }   

    if ($number -ge 2 -or $number -eq 0) { return ($ct + $pluralLabel)}
    return ($ct + $singularLabel)
}   
                                                                                                         
<#
.SYNOPSIS
Writes a named variable in humanized form.

.DESCRIPTION
Long description

.PARAMETER variableName
Parameter description

.PARAMETER singularLabel
Parameter description

.PARAMETER pluralLabel
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>

$Script:WriteCounts = @([PSCustomObject]@{
    CountLabel = '';
    Count      = 0;
    Tag        = 'x';
})             

Function Write-Count ([string]$variableName = $null, [string]$singularLabel, [string]$pluralLabel = $null) {
    $countLabel = ""

    $countLabel = $variableName.Humanize()
    $number = Get-Variable -Name $variableName -Scope Global -Value

    if ($number -eq 1) {
        $Script:WriteCounts+= [PSCustomObject]@{
            CountLabel = $countLabel;
            Count      = $number;
            Tag        = $singularLabel;
        }
        return 
    } else {
        If ([String]::IsNullOrEmpty($pluralLabel)) {
            $LastCharacter = Right $singularLabel
            $Last2Characters = Right $singularLabel 2
            $SecondLastCharacter = Left $Last2Characters # Concise. Dont repit yourself.

            $Irregulars     = @{Man = 'Men'; Foot='Feet';Mouse='Mice';Person='People';Child='Children';'Goose'='Geese';Ox='Oxen';Woman='Women';Genus='Genera';Index='Indices';Datum='Data'}
            $NonCount= @('Moose', 'Fish', 'Species', 'Deer', 'Aircraft', 'Series', 'Salmon', 'Trout', 'Swine', 'Sheep')
            $OnlyS = @('photo', 'halo', 'piano')                                                                                                                
            $ExceptionsToFE = @('chef', 'roof')      
            
            if ($singularLabel -in $NonCount) {
                $plurallabel = $singularLabel 
            }                                                                        
            elseif ($singularLabel -in $Irregulars.Keys) {
                $plurallabel = $Irregulars[$singularLabel]
            }
            elseif ($singularLabel -in $OnlyS -or $singularLabel -in $ExceptionsToFE) {
                $plurallabel = $singularLabel + 's'
            }
            elseif ($LastCharacter -in @('s', 'ss', 'ch', 'x', 'sh', 'o', 'z') -or $Last2Characters -in @('s', 'ss', 'ch', 'x', 'sh', 'o', 'z')) { 
                $pluralLabel = $singularLabel + 'es'
            }  
            elseif ($Last2Characters -in @('f', 'fe')) { 
                $pluralLabel = $singularLabel.TrimEnd($Last2Characters) + 'ves' # Wife => Wives
            }  
            elseif ($LastCharacter -in @('f', 'fe')) { 
                $pluralLabel = $singularLabel.TrimEnd($LastCharacter) + 'ves'   # Calf => Calves
            }  
            elseif ($Last2Characters -in @('us')) {  
                $pluralLabel = $singularLabel.TrimEnd($Last2Characters) + 'i'   # Cactus => Cacti
            }  
            elseif ($Last2Characters -in @('is')) {  
                $pluralLabel = $singularLabel.TrimEnd($Last2Characters) + 'es'   # Analysis => analyses
            }  
            elseif ($Last2Characters -in @('on')) {  
                $pluralLabel = $singularLabel.TrimEnd($Last2Characters) + 'a'   # Phenomenon => Phenomena
            }  
            elseif ($LastCharacter -in @('y') -and $SecondLastCharacter -notin @('a','e','i','o','u')) { 
                $pluralLabel = $singularLabel.TrimEnd($LastCharacter) + 'ies' # City => Cities
            }  
            else {
                $pluralLabel = $singularLabel + 's'                             # Cat => Cats
            }
        }

        $Script:WriteCounts+= [PSCustomObject]@{
            CountLabel = $countLabel;
            Count      = $number;
            Tag        = $pluralLabel;
        }
    }   
}   

# TODO: Inflector methods. https://github.com/Humanizr/Humanizer?tab=readme-ov-file#inflector-methods
