
[CmdletBinding()]
param(
    [Parameter(Mandatory=$False, HelpMessage='Tenant ID (This is a GUID which represents the "Directory ID" of the AzureAD tenant into which you want to create the apps')]
    [string] $tenantId,
    [Parameter(Mandatory=$False, HelpMessage='Azure environment to use while running the script. Default = Global')]
    [string] $azureEnvironmentName
)

Function RemoveUser([string]$userPrincipal)
{
    Remove-MgUser -UserId $userPrincipal
}

Function CleanupRolesUsersAndRoleAssignments
{
    if (!$azureEnvironmentName)
    {
        $azureEnvironmentName = "Global"
    }

    Write-Host "Connecting to Microsoft Graph"

    if ($tenantId -eq "") 
    {
        Connect-MgGraph -Scopes "Application.ReadWrite.All User.ReadWrite.All" -Environment $azureEnvironmentName
        $tenantId = (Get-MgContext).TenantId
    }
    else 
    {
        Connect-MgGraph -TenantId $tenantId -Scopes "Application.ReadWrite.All User.ReadWrite.All" -Environment $azureEnvironmentName
    }


    $userAccount = (Get-MgContext).Account
    $split = $userAccount.Split("@")
    $tenantName = $split[1]
    Write-Host "get the AAD application (msal-angular-app)"
    $app = Get-MgApplication -Filter "DisplayName eq 'msal-angular-app'" 
    if ($app)
    {
        $appName = $app.DisplayName
        $userEmail =  $appName +"-" + "TaskAdmin" + "@" + $tenantName
        RemoveUser -userPrincipal $userEmail
        Write-Host "user name ($userEmail)"
        $userEmail =  $appName +"-" + "TaskUser" + "@" + $tenantName
        RemoveUser -userPrincipal $userEmail
        Write-Host "user name ($userEmail)"
    }
}

if ($null -eq (Get-Module -ListAvailable -Name "Microsoft.Graph.Authentication")) {
    Install-Module "Microsoft.Graph.Authentication" -Scope CurrentUser 
}

Import-Module Microsoft.Graph.Authentication

if ($null -eq (Get-Module -ListAvailable -Name "Microsoft.Graph.Applications")) {
    Install-Module "Microsoft.Graph.Applications" -Scope CurrentUser 
}

Import-Module Microsoft.Graph.Applications

if ($null -eq (Get-Module -ListAvailable -Name "Microsoft.Graph.Users")) {
    Install-Module "Microsoft.Graph.Users" -Scope CurrentUser 
}

Import-Module Microsoft.Graph.Users

# Run interactively (will ask you for the tenant ID)
CleanupRolesUsersAndRoleAssignments -tenantId $tenantId -environment $azureEnvironmentName

Write-Host "Disconnecting from tenant"
Disconnect-MgGraph