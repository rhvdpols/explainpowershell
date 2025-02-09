$modules = Get-Content "$PSScriptRoot/../../explainpowershell.metadata/defaultModules.json" | ConvertFrom-Json

$pre = @'
using System;
using System.Collections.Generic;

namespace ExplainPowershell.SyntaxAnalyzer
{
    public static partial class Helpers {
        public static string ResolveAlias(string cmdName)
        {
            var dict = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
'@

$post = @'
            };

            return dict.ContainsKey(cmdName) ? dict[cmdName] : null;
        }
    }
}
'@

$body = Get-Alias
    # We only want to 'recognize' aliases from the core PowerShell modules, so we exclude other modules' aliases here
    | Where-Object { -not $_.Source -or $_.Source -in $modules.Name }
    | ForEach-Object {
@"
                { `"$($_.Name)`", `"$($_.Definition)`" },
"@
}


$pre, $body, $post | Out-File -FilePath "$PSScriptRoot\..\Helpers\Alias.cs" -Force