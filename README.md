# explainpowershell

PowerShell version of [explainshell.com](explainshell.com)

Initial idea [published on Twitter](https://twitter.com/Jawz_84/status/1279856845570682880?s=20)

On ExplainShell.com, you can enter a Linux terminal oneliner, and the site will analyze it, and return snippets from the proper man-pages, in an effort to explain the oneliner. 
I would like to create the same thing but for PowerShell. 

At this point I have a proof of concept that kind of looks like the screenshot below. 

![screenshot](./explainpowershell_website_screenshot.jpg)

## Azure Resources overview

* C# Azure Function backend API that analyzes PowerShell oneliners.
* Azure Storage that hosts Blazor Wasm pages as a static website.
* Azure Storage Table in which all help metadata is for currently supported modules.

![azure resources](./AzViz.png)