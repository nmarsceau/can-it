function Read-CannedResponse {
    param($cannedResponses, $cannedResponseName)
    if ($null -eq $cannedResponseName) {
        Write-Output "`nPlease specify either the name or ID of a canned response.`n`nRun ``can-it ls`` to list all canned responses.`n"
        Exit
    }
    try {
        $cannedResponseIndex = [int] $cannedResponseName
        if ($cannedResponseIndex -gt 0 -and $cannedResponses.Length -ge $cannedResponseIndex) {
            return $cannedResponses[$cannedResponseIndex - 1]
        }
    }
    catch {
        foreach ($item in $cannedResponses) {
            if ($item.name -eq $cannedResponseName) {
                return $item
            }
        }
    }
    Write-Output "`nCanned response '$cannedResponseName' does not exist.`n"
    Exit
}


function Write-CannedResponse {
    param($cannedResponseName, $cannedResponseBody)
    $marginLeft = " " * [math]::floor(($Host.UI.RawUI.WindowSize.Width - $cannedResponseName.Length) / 2)
    return "`n`n$marginLeft$cannedResponseName`n" + (Build-HorizontalRule) + "`n`n$cannedResponseBody`n`n" + (Build-HorizontalRule) + "`n`n"
}


function Build-HorizontalRule {
    return ("-" * $Host.UI.RawUI.WindowSize.Width)
}


function Write-CannedResponses {
    param($cannedResponses);
    if ($null -eq $cannedResponses -or $cannedResponses.Length -eq 0) {
        Write-Output "`nNo canned responses yet.`n"
    }
    else {
        $cannedResponses | Format-Table `
            @{Label="Index"; Expression={$cannedResponses.IndexOf($_) + 1;}; Align="center"}, `
            @{Label="Name"; Expression={$_.name}}
    }
}


function Show-CannedResponse {
    param($cannedResponse)
    Write-Output (Write-CannedResponse $cannedResponse.name $cannedResponse.body)
}


function Use-CannedResponse {
    param($cannedResponse)
    Clear-Host
    Write-Output (Write-CannedResponse $cannedResponse.name $cannedResponse.body)
    foreach ($field in $cannedResponse.fields) {
        $fieldPrompt = $field
        if ($null -ne $cannedResponse.defaults.$field) {
            $cannedResponse.defaults.$field = $cannedResponse.defaults.$field.Trim()
            $fieldPrompt += (" [" + $cannedResponse.defaults.$field + "]")
        }
        $fieldValue = (Read-Host $fieldPrompt).Trim()
        if ($null -ne $cannedResponse.defaults.$field -and $fieldValue -eq "") {
            $fieldValue = $cannedResponse.defaults.$field
        }
        $cannedResponse.body = $cannedResponse.body.Replace("{{ " + $field + " }}", $fieldValue)
        Clear-Host
        Write-Output (Write-CannedResponse $cannedResponse.name $cannedResponse.body)
    }
    Set-Clipboard -Value $cannedResponse.body
    Write-Output "`u{2705} Copied to clipboard`n"
    Start-Sleep -Seconds 2
}

<#
    .SYNOPSIS
    Can-It is a tool for using canned responses.

    .DESCRIPTION
    Can-It stores canned responses and provides several functions for using them.

    Supported Actions
        ls
            Prints the names and index numbers of all canned responses from the config file.

        peek [canned response]
            Prints the specified canned response.
            Provide the name or index number of a canned response as a parameter.

        use [canned response]
            Uses the specified canned response.
            Provide the name or index number of a canned response as a parameter.

            The canned response will be printed to the console, and you will be prompted
            to provide a replacement value for each placeholder in it. As you fill in each
            placeholder, the canned response will update to include what you entered.
            Once you fill in the last placeholder, the complete canned response
            will be copied to your clipboard.

    .NOTES
    There is currently no facility for adding or removing canned responses
    through the command line interface. To add, remove, or reorder canned
    responses, edit the config file directly.
    
    The config file is named can-it.json, and it should be located in the
    same directly as this script.
    
    This module contains an example config file, example-can-it.json.
#>
function Invoke-CanIt {
    [CmdletBinding()]
    param([string]$Action, [Parameter(ValueFromPipeline)][string]$CannedResponse)
    begin {
        $configFilePath = "$PSScriptRoot\can-it.json"
        if (-not (Test-Path -Path $configFilePath -PathType Leaf)) {
            $null = New-Item -ItemType File -Path $configFilePath -Value '{"cannedResponses":[]}' -Force
        }
        $config = Get-Content $configFilePath | ConvertFrom-Json
    }
    process {
        switch ($Action) {
            "ls" {
                Write-CannedResponses $config.cannedResponses
            }
            "peek" {
                Show-CannedResponse (Read-CannedResponse $config.cannedResponses $CannedResponse)
            }
            "use" {
                Use-CannedResponse (Read-CannedResponse $config.cannedResponses $CannedResponse)
            }
            default {
                Write-Output 'Invalid action specified. Run `Help can-it` for additional information.'
            }
        }
    }
}

Set-Alias "can-it" Invoke-CanIt
