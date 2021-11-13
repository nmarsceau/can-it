param($Action, $Object);

$cannedResponses = (Get-Content "$PSScriptRoot\can-it.json" | ConvertFrom-Json).cannedResponses;

function selectCannedResponse {
  param($cannedResponseName);
  if ($null -eq $cannedResponseName) {
    canItList;
    $cannedResponseName = Read-Host "Please select a canned response from the list above";
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
    $cannedResponse.body = $cannedResponse.body.Replace("{{ " + $field + " }}", (Read-Host $field).Trim());
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

function canItAdd {
  param($cannedResponse);
  Write-Output "`nComing soon :)`n";
}

function canItRm {
  param($cannedResponse);
  ConvertTo-Json `
    @{cannedResponses = $cannedResponses.where({ $_.name -ne $cannedResponse.name })} `
    -Depth 10 `
    | Set-Content "$PSScriptRoot\can-it.json";
}

function canItHelp {
  Write-Output "`nCan-It is a tool for using canned responses.";
  Write-Output "Canned response templates are stored in can-it.json and accessed via the command line.";
  Write-Output "Use example-can-it.json as an example and define your own can-it.json.";

  Write-Output "`nRun ``can-it list`` to view a list of your canned responses, and ``can-it use`` to use one.";
  Write-Output "As you fill in each placeholder, the output will be updated to include what you entered.";
  Write-Output "When you have filled in each placeholder, the output will be copied to your clipboard.`n";
}

switch ($Action) {
  "list" {
    canItList;
    Break;
  }
  "use" {
    canItUse(selectCannedResponse $Object);
    Break;
  }
  "add" {
    canItAdd($Object);
    Break;
  }
  "rm" {
    canItRm(selectCannedResponse $Object);
    Break;
  }
  default {
    canItHelp;
    Break;
  }
}
