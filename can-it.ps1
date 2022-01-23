param($Action, $Object);

$cannedResponses = (Get-Content "$PSScriptRoot\can-it.json" | ConvertFrom-Json).cannedResponses;

function selectCannedResponse {
    param($cannedResponseName);
    if ($null -eq $cannedResponseName) {
        Write-Output "`nPlease specify either the name or ID of a canned response.`n`nRun ``can-it list`` to list all canned responses.`n";
        Exit;
    }
    try {
        $cannedResponseIndex = [int] $cannedResponseName;
        if ($cannedResponseIndex -gt 0 -and $cannedResponses.Length -ge $cannedResponseIndex) {
            return $cannedResponses[$cannedResponseIndex - 1];
        }
    }
    catch {
        foreach ($item in $cannedResponses) {
            if ($item.name -eq $cannedResponseName) {
                return $item;
            }
        }
    }
    Write-Output "`nCanned response '$cannedResponseName' does not exist.`n";
    Exit;
}

function canItList {
    $cannedResponses | Format-Table `
        @{Label="Index"; Expression={$cannedResponses.IndexOf($_) + 1;}; Align="center"}, `
        @{Label="Name"; Expression={$_.name}} `
    ;
}

function canItUse {
    param($cannedResponse);
    Clear-Host;
    Write-Output (outputCannedResponse $cannedResponse.name $cannedResponse.body);
    foreach ($field in $cannedResponse.fields) {
        $fieldPrompt = $field;
        If ($null -ne $cannedResponse.defaults.$field) {
            $cannedResponse.defaults.$field = $cannedResponse.defaults.$field.Trim();
            $fieldPrompt += (" [" + $cannedResponse.defaults.$field + "]");
        }
        $fieldValue = (Read-Host $fieldPrompt).Trim();
        If ($null -ne $cannedResponse.defaults.$field -and $fieldValue -eq "") {
            $fieldValue = $cannedResponse.defaults.$field;
        }
        $cannedResponse.body = $cannedResponse.body.Replace("{{ " + $field + " }}", $fieldValue);
        Clear-Host;
        Write-Output (outputCannedResponse $cannedResponse.name $cannedResponse.body);
    }
    Set-Clipboard -Value $cannedResponse.body;
    Write-Output "`u{2705} Copied to clipboard`n";
}

function outputCannedResponse {
    param($cannedResponseName, $cannedResponseBody);
    $marginLeft = " " * [math]::floor(($Host.UI.RawUI.WindowSize.Width - $cannedResponseName.Length) / 2);
    return "`n`n$marginLeft$cannedResponseName`n" + (horizontalRule) + "`n`n$cannedResponseBody`n`n" + (horizontalRule) + "`n`n";
}

function horizontalRule {
    return ("-" * $Host.UI.RawUI.WindowSize.Width);
}

function canItPeek {
    param($cannedResponse);
    Write-Output (outputCannedResponse $cannedResponse.name $cannedResponse.body);
}

function canItHelp {
    Write-Output (Get-Content "$PSScriptRoot\help.txt").Replace('{{ script root }}', $PSScriptRoot);
}

switch ($Action) {
    "list" {
        canItList;
        Break;
    }
    "peek" {
        canItPeek (selectCannedResponse $Object);
        Break;
    }
    "use" {
        canItUse (selectCannedResponse $Object);
        Break;
    }
    default {
        canItHelp;
        Break;
    }
}
