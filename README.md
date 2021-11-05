# Can It!
Can It! is a PowerShell tool for managing and using canned responses.

To install this program:
1. Clone this repository to your computer.
2. Define an alias in your PowerShell profile.
    `Set-Alias -Name "can-it" -Value "C:\path\to\can-it.ps1";`
3. Define your canned responses in `can-it.json`, using `example-can-it.json` as a guide.

Run `can-it list` to view a list of your canned responses, and `can-it use` to use one.
As you fill in each placeholder, the output will be updated to include what you entered.
When you have filled in each placeholder, the output will be copied to your clipboard.
