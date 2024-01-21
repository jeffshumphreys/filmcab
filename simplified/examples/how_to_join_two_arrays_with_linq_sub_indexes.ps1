<#
    Making as purty as possible so I can understand it later.
#>
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Scope='Function', Target='Log-*')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')] # Not just functions! Everywhere! No idea what the 'Scope' name is.  If you set scope to Function and there are any functions, the rest of the code will still show squiggles.
param()

<#
.SYNOPSIS
Cool (Kewl) way to generate array indexes (aka ordinal) from within a Select. This subindex is the ONLY way you can join two unindexed arrays that are linked only by their position in the array.

.DESCRIPTION
No, Object[] arrays don't have some magic internal subindex.

.EXAMPLE
An example

.NOTES
General notes
#>
Function New-ArrayIndex {
    $subindex = 0;
    {
        $subindex
        $script:subindex+= 1
    }.GetNewClosure()
} 

$indexFunctorLeft = New-ArrayIndex
$indexFunctorRight = New-ArrayIndex

# Now we create ordinal array item position indexes for one side of our join.  We need TWO functors otherwise the $rightSideOfJoin indexing will just follow on the last subindex of the $leftSideOfJoin.
$leftSideOfJoin = 
(Get-WinEvent -ListProvider 'Microsoft-Windows-TaskScheduler').Events|
    Where Template -ne ''|                                                        # Empty templates on some events break any further expansion.
    Select @{Name='OrdinalPositionInArray'; Expression={ & $indexFunctorLeft}},
           @{Name='EventId'               ; Expression={ $_.Id}}, 
           @{Name='EventIdVersionNo'      ; Expression={ $_.Version}}

$rightSideOfJoin = 
(Get-WinEvent -ListProvider 'Microsoft-Windows-TaskScheduler').Events|
    Where Template -ne ''|
    Select -Expand Template|
    Select-Xml -XPath '*'|
    Select -Expand Node|
    Select data|
    Select @{Name='OrdinalPositionInArray' ; Expression={ & $indexFunctorRight}}, 
           @{Name='EventPropertyNamesArray'; Expression={ $_.data}}                        # "data" is so generic a name.

$LinqJoinedData = [System.Linq.Enumerable]::Join(
    $leftSideOfJoin,
    $rightSideOfJoin,
    [System.Func[Object,string]] {param ($leftArrayRow);$leftArrayRow.OrdinalPositionInArray},
    [System.Func[Object,string]]{param ($rightArrayRow);$rightArrayRow.OrdinalPositionInArray},
    [System.Func[Object,Object,Object]]{
        param ($leftArrayRow, $rightArrayRow);
        New-Object -TypeName PSObject -Property @{
            EventPropertyNamesArray = $rightArrayRow.EventPropertyNamesArray;
            EventId = $leftArrayRow.EventId;                       
            EventIdVersionNo = $leftArrayRow.EventIdVersionNo;
            OrdinalPositionInArray = $leftArrayRow.OrdinalPositionInArray;   
        }
    }
)
$JoinedArray = [System.Linq.Enumerable]::ToArray($LinqJoinedData)

Function New-ArraySubIndex {
    $PreviousEventId = 0;
    $PreviousEventIdVersionNo = 0;
    $subindex = 0;
    {                     
        param($EventId, $EventIdVersionNo)                                   # Had no idea you could do this! Have inner params, I mean. Don't see any docs on this.
        if ($EventId -ne $PreviousEventId -or $EventIdVersionNo -ne $PreviousEventIdVersionNo) {
            $script:subindex = 0
            $script:PreviousEventId = $EventId            # Really old-school looping and detecting group changes.
            $script:PreviousEventIdVersionNo = $EventIdVersionNo
            $subindex
        } else {
            $script:subindex+= 1
            $subindex
        }
    }.GetNewClosure()
}       

$subIndexFunctor = New-ArraySubIndex

$SubindexedJoinedArray = 
$JoinedArray|
    Select EventId, 
           EventIdVersionNo, 
           OrdinalPositionInArray -ExpandProperty EventPropertyNamesArray|
    Select OrdinalPositionInArray, 
           @{Name='subIndex'; Expression={ 
               Invoke-Command $subIndexFunctor -ArgumentList $_.EventId, $_.EventIdVersionNo}   # Bam! Da Magic.
           }, 
           EventId, 
           EventIdVersionNo, 
           @{Name='EventIdPropertyName'; Expression= {$_.Name}}

$allTheTestsTogether = ""

# For each property, let's get a distinct list of event ids to trap with an 'if id in (1,2,3,4)'

$SubindexedJoinedArray|
Sort EventIdPropertyName|
Group EventIdPropertyName|
Select @{Name='EventIdPropertyName'; Expression= {$_.Name}},
       @{Name='EventIdsAttachedToThisPropertyName'; Expression= {$_.Group}}|
ForEach-Object {
    $EventIdPropertyName = $_.EventIdPropertyName
    $EventIds = $_.EventIdsAttachedToThisPropertyName|
        Select -Unique EventId # They double and triple when multiple versions exist.
    $joinControlParams = @{
        Property   = "EventId"
        FormatString = '{0}'
        Separator = ","
    }  

    $EventIdsAsCommaDelimitedString = $EventIds|
        Join-String @joinControlParams # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/join-string?view=powershell-7.4
        
    $EventIdsAtThisSubIndex = $_.EventIdsAttachedToThisPropertyName|
        Select EventId, EventIdVersionNo, subIndex|
        Group subIndex, EventIdVersionNo|
        Select @{Name='SubIndex'; Expression= { 
            if ($_.Name.GetType().Name -ne 'System.Char' -and @($_.Name).GetType().Name -eq 'Object[]') 
            {
                $_.Name[0]
            } 
            else {$_.Name}
            }},
           @{Name='EventIdsAttachedToThisPropertyNameAndSubIndex'; Expression= {$_.Group}}
               
    $codeToProcessEachPropertiesEventIds = ""

    $howmanyifs = $EventIdsAtThisSubIndex.Count - 1
    for ($i = 0; $i -le $howmanyifs;$i++) {
        $subIndex = $EventIdsAtThisSubIndex[$i].SubIndex
        $eventidsatthisdepth = $EventIdsAtThisSubIndex[$i]|
            Select -Expand EventIdsAttachedToThisPropertyNameAndSubIndex|
            Select -Unique EventId
        $EventIdVersionNoForThisDepth = @($EventIdsAtThisSubIndex[$i]|
            Select -Expand EventIdsAttachedToThisPropertyNameAndSubIndex|
            Select -Unique EventIdVersionNo|Select EventIdVersionNo).EventIdVersionNo

        $eventidsatdepthAsString = $eventidsatthisdepth|
            Join-String @joinControlParams # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/join-string?view=powershell-7.4
            
        $codeToProcessEachPropertiesEventIds+= "          "
        if ($i -gt 0) {
            $codeToProcessEachPropertiesEventIds+= "else"
        }

        $codeToProcessEachPropertiesEventIds+= "if (`$_.Id -in @($eventidsatdepthAsString) -and `$_.Version -eq $EventIdVersionNoForThisDepth) {
            `$_.Properties[$subIndex].Value
            }"

    }

    $testline = 
"        @{Name='$EventIdPropertyName'; Expression = {
            if (`$_.Id -in @($eventIdsAsCommaDelimitedString)) {
                $codeToProcessEachPropertiesEventIds
            }
         }},
"
    #$testline
    $allTheTestsTogether+= $testline
}
                                           
$allTheTestsTogether = $allTheTestsTogether.Trim()
$allTheTestsTogether = $allTheTestsTogether.TrimEnd(',')
$allTheTestsTogether+= '|'  # + [System.Environment]::NewLine
$allTheTestsTogether
$allTheTestsTogether|Out-File -FilePath "pull_and_translate_all_scheduled_task_run_history-v2.inset.txt"