---
page_type: sample
name: Angular single-page application calling a protected web API and using App Roles to implement Role-Based Access Control
services: ms-identity
languages:
 - typescript
 - csharp
 - javascript
products:
 - azure-active-directory
 - msal-js
 - msal-angular
 - microsoft-identity-web
urlFragment: ms-identity-javascript-angular-tutorial
description: Angular single-page application calling a protected web API using App Roles to implement Role-Based Access Control
---

# Angular single-page application calling a protected web API and using App Roles to implement Role-Based Access Control

* [Overview](#overview)
* [Scenario](#scenario)
* [Prerequisites](#prerequisites)
* [Setup the sample](#setup-the-sample)
* [Explore the sample](#explore-the-sample)
* [Troubleshooting](#troubleshooting)
* [About the code](#about-the-code)
* [Next Steps](#next-steps)
* [Contributing](#contributing)
* [Learn More](#learn-more)

## Overview

This sample demonstrates a cross-platform application suite involving an Angular single-page application (*TodoListSPA*) calling an ASP.NET Core web API (*TodoListAPI*) secured with the Microsoft identity platform. In doing so, it implements **Role-based Access Control** (RBAC) by using Azure AD **App Roles**.

Role based access control in Azure AD can be done with **Delegated** and **App** permissions and **Security Groups** as well. we will cover RBAC using Security Groups in the [next tutorial](../2-call-api-groups/README.md). **Delegated** and **App** permissions, **Security Groups** and **App Roles** in Azure AD are by no means mutually exclusive - they can be used in tandem to provide even finer grained access control.

In the sample, a **dashboard** component allows signed-in users to see the tasks assigned to users and is only accessible by users under an **app role** named **TaskAdmin**.

> :information_source: See the community call: [Implement authorization in your applications with the Microsoft identity platform](https://www.youtube.com/watch?v=LRoc-na27l0)

> :information_source: See the community call: [Deep dive on using MSAL.js to integrate Angular single-page applications with Azure Active Directory](https://www.youtube.com/watch?v=EJey9KP1dZA)

## Scenario

- The **TodoListSPA** uses [MSAL Angular](https://github.com/AzureAD/microsoft-authentication-library-for-js/tree/dev/lib/msal-angular) to authenticate a user with the Microsoft identity platform.
- The app then obtains an [access token](https://docs.microsoft.com/azure/active-directory/develop/access-tokens) from Azure Active Directory (Azure AD) on behalf of the authenticated user for the **TodoListAPI**.
- **TodoListAPI** uses [Microsoft.Identity.Web](https://github.com/AzureAD/microsoft-identity-web) to protect its endpoint and accept only authorized calls.

![Topology](./ReadmeFiles/topology.png)

## Contents

| File/folder                         | Description                                                |
|-------------------------------------|------------------------------------------------------------|
| `SPA/src/app/auth-config.ts`        | Authentication parameters for SPA project reside here.     |
| `SPA/src/app/app.module.ts`         | MSAL Angular is initialized here.                          |
| `SPA/src/app/role-guard.service.ts` | This service protects other components that require user to be in a role. |
| `API/appsettings.json`              | Authentication parameters for API project reside here.     |
| `API/Startup.cs`                    | Microsoft.Identity.Web is initialized here.                |

## Prerequisites

* Either [Visual Studio](https://visualstudio.microsoft.com/downloads/) or [Visual Studio Code](https://code.visualstudio.com/download) and [.NET Core SDK ](https://www.microsoft.com/net/learn/get-started). This sample targets .NET v6.0
* An **Azure AD** tenant. For more information, see: [How to get an Azure AD tenant](https://docs.microsoft.com/azure/active-directory/develop/test-setup-environment#get-a-test-tenant)
* At least **two** user accounts in your Azure AD tenant.

## Setup the sample

Using a command line interface such as VS Code integrated terminal, follow the steps below:

### Step 1. Install .NET Core API dependencies

```console
    git clone https://github.com/Azure-Samples/ms-identity-javascript-angular-tutorial.git
```

or download and extract the repository .zip file.

> :warning: To avoid path length limitations on Windows, we recommend cloning into a directory near the root of your drive.

### Step 2. Install .NET Core API dependencies

```console
    cd ms-identity-javascript-angular-tutorial
    cd 5-AccessControl/1-call-api-roles/API
    dotnet restore
```

### Step 3. Trust development certificates

```console
    dotnet dev-certs https --clean
    dotnet dev-certs https --trust
```

For more information and potential issues, see: [HTTPS in .NET Core](https://docs.microsoft.com/aspnet/core/security/enforcing-ssl).

### Step 4. Install Angular SPA dependencies

```console
    cd ../
    cd SPA
    npm install
```

### Step 5: Register the sample application(s) in your tenant

There is one project in this sample. To register it, you can:

- follow the steps below for manually register your apps
- or use PowerShell scripts that:
  - **automatically** creates the Azure AD applications and related objects (passwords, permissions, dependencies) for you.
  - modify the projects' configuration files.

  <details>
   <summary>Expand this section if you want to use this automation:</summary>

    > :warning: If you have never used **Microsoft Graph PowerShell** before, we recommend you go through the [App Creation Scripts Guide](./AppCreationScripts/AppCreationScripts.md) once to ensure that your environment is prepared correctly for this step.
  
    1. On Windows, run PowerShell as **Administrator** and navigate to the root of the cloned directory
    1. In PowerShell run:

       ```PowerShell
       Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
       ```

    1. Run the script to create your Azure AD application and configure the code of the sample application accordingly.
    1. For interactive process -in PowerShell, run:

       ```PowerShell
       cd .\AppCreationScripts\
       .\Configure.ps1 -TenantId "[Optional] - your tenant id" -AzureEnvironmentName "[Optional] - Azure environment, defaults to 'Global'"
       ```

    > Other ways of running the scripts are described in [App Creation Scripts guide](./AppCreationScripts/AppCreationScripts.md). The scripts also provide a guide to automated application registration, configuration and removal which can help in your CI/CD scenarios.

  </details>

#### Choose the Azure AD tenant where you want to create your applications

To manually register the apps, as a first step you'll need to:

1. Sign in to the [Azure portal](https://portal.azure.com).
1. If your account is present in more than one Azure AD tenant, select your profile at the top right corner in the menu on top of the page, and then **switch directory** to change your portal session to the desired Azure AD tenant.

#### Register the app (msal-angular-app)

> :information_source: Below, we are using a single app registration for both SPA and web API projects.

1. Navigate to the [Azure portal](https://portal.azure.com) and select the **Azure Active Directory** service.
1. Select the **App Registrations** blade on the left, then select **New registration**.
1. In the **Register an application page** that appears, enter your application's registration information:
    1. In the **Name** section, enter a meaningful application name that will be displayed to users of the app, for example `msal-angular-app`.
    1. Under **Supported account types**, select **Accounts in this organizational directory only**
    1. Select **Register** to create the application.
1. In the **Overview** blade, find and note the **Application (client) ID**. You use this value in your app's configuration file(s) later in your code.
1. In the app's registration screen, select the **Authentication** blade to the left.
1. If you don't have a platform added, select **Add a platform** and select the **Single-page application** option.
    1. In the **Redirect URI** section enter the following redirect URIs:
        1. `http://localhost:4200/`
        1. `http://localhost:4200/auth`
    1. Click **Save** to save your changes.
1. In the app's registration screen, select the **Expose an API** blade to the left to open the page where you can publish the permission as an API for which client applications can obtain [access tokens](https://aka.ms/access-tokens) for. The first thing that we need to do is to declare the unique [resource](https://docs.microsoft.com/azure/active-directory/develop/v2-oauth2-auth-code-flow) URI that the clients will be using to obtain access tokens for this API. To declare an resource URI(Application ID URI), follow the following steps:
    1. Select **Set** next to the **Application ID URI** to generate a URI that is unique for this app.
    1. For this sample, accept the proposed Application ID URI (`api://{clientId}`) by selecting **Save**. Read more about Application ID URI at [Validation differences by supported account types \(signInAudience\)](https://docs.microsoft.com/azure/active-directory/develop/supported-accounts-validation).
 
##### Publish Delegated Permissions

1. All APIs must publish a minimum of one [scope](https://docs.microsoft.com/azure/active-directory/develop/v2-oauth2-auth-code-flow#request-an-authorization-code), also called [Delegated Permission](https://docs.microsoft.com/azure/active-directory/develop/v2-permissions-and-consent#permission-types), for the client apps to obtain an access token for a *user* successfully. To publish a scope, follow these steps:
1. Select **Add a scope** button open the **Add a scope** screen and Enter the values as indicated below:
    1. For **Scope name**, use `access_as_user`.
    1. Select **Admins and users** options for **Who can consent?**.
    1. For **Admin consent display name** type in *Access 'msal-angular-app' as the signed-in user.*.
    1. For **Admin consent description** type in *Allow the app to access the 'msal-angular-app' as a signed-in user.*.
    1. For **User consent display name** type in *Access 'msal-angular-app' on your behalf.*.
    1. For **User consent description** type in *Allow the app to access the 'msal-angular-app' on your behalf.*.
    1. Keep **State** as **Enabled**.
    1. Select the **Add scope** button on the bottom to save this scope.
1. Select the **Manifest** blade on the left.
    1. Set `accessTokenAcceptedVersion` property to **2**.
    1. Select on **Save**.

> :information_source:  Follow  [the principle of least privilege](https://docs.microsoft.com/azure/active-directory/develop/secure-least-privileged-access) whenever you are publishing permissions for a web API.

##### Grant Delegated Permissions to msal-angular-app

1. Since this app signs-in users, we will now proceed to select **delegated permissions**, which is is required by apps signing-in users.
   1. In the app's registration screen, select the **API permissions** blade in the left to open the page where we add access to the APIs that your application needs:
   1. Select the **Add a permission** button and then,
   1. Ensure that the **My APIs** tab is selected.
   1. In the list of APIs, select the API `msal-angular-app`.
      * Since this app signs-in users, we will now proceed to select **delegated permissions**, which is is requested by apps when signing-in users.
           1. In the **Delegated permissions** section, select the **access_as_user** in the list. Use the search box if necessary.
   1. Select the **Add permissions** button at the bottom.

##### Publish Application Roles for users and groups

1. Still on the same app registration, select the **App roles** blade to the left.
1. Select **Create app role**:
    1. For **Display name**, enter a suitable name, for instance **TaskAdmin**.
    1. For **Allowed member types**, choose **User**.
    1. For **Value**, enter **TaskAdmin**.
    1. For **Description**, enter **Admins can read any user's todo list**.
    > Repeat the steps above for another role named **TaskUser**
    1. Select **Apply** to save your changes. 

To add users to this app role, follow the guidelines here: [Assign users and groups to roles](https://docs.microsoft.com/azure/active-directory/develop/howto-add-app-roles-in-azure-ad-apps#assign-users-and-groups-to-roles).

> :bulb: **Important security tip**
>
> When you set **User assignment required?** to **Yes**, Azure AD will check that only users assigned to your application in the **Users and groups** blade are able to sign-in to your app. You can assign users directly or by assigning security groups they belong to.

For more information, see: [How to: Add app roles in your application and receive them in the token](https://docs.microsoft.com/azure/active-directory/develop/howto-add-app-roles-in-azure-ad-apps)

##### (Optional) Configure Optional Claims

1. Still on the same app registration, select the **Token configuration** blade to the left.
1. Select **Add optional claim**:
    1. Select **optional claim type**, then choose **Access**.
    1. Select the optional claim **acct**. 
        > Provides user's account status in tenant. If the user is a member of the tenant, the value is 0. If they're a guest, the value is 1.
    1. Select **Add** to save your changes.

##### Configure the client app (msal-angular-app) to use your app registration

Open the project in your IDE (like Visual Studio or Visual Studio Code) to configure the code.

> In the steps below, "ClientID" is the same as "Application ID" or "AppId".

1. Open the `API\TodoListAPI\appsettings.json` file.
1. Find the string `Enter the ID of your Azure AD tenant copied from the Azure portal` and replace the existing value with your Azure AD tenant/directory ID.
1. Find the string `Enter the application ID (clientId) of the 'TodoListAPI' application copied from the Azure portal` and replace the existing value with the application ID (clientId) of `msal-angular-app` app copied from the Azure portal.

1. Open the `SPA\src\app\auth-config.ts` file.
1. Find the string `Enter_the_Application_Id_Here` and replace the existing value with the application ID (clientId) of `msal-angular-app` app copied from the Azure portal.
1. Find the string `Enter_the_Tenant_Info_Here` and replace the existing value with your Azure AD tenant ID.
1. Find the string `Enter_the_Web_Api_Application_Id_Here` and replace the existing value with the application ID (clientId) of the web API -in this scenario, this is the same application ID with `msal-angular-app`.

### Step 6: Running the sample

Using a command line interface such as **VS Code** integrated terminal, locate the application directory. Then:  

```console
   cd SPA
   npm start
```

In a separate console window, execute the following commands:

```console
   cd API\TodoListAPI
   dotnet run
```

## Explore the sample

1. Open your browser and navigate to `http://localhost:4200`.
2. Sign-in using the button on top-right:

![login](./ReadmeFiles/ch1_login.png)

1. Click on the **Get My Tasks** button to access your (the signed-in user's) todo list:

![todolist](./ReadmeFiles/ch1_todolist.png)

1. If the signed-in user has the right privileges (i.e. in the right "role"), click on the **See All Tasks** button to access every users' todo list:

![dashboard](./ReadmeFiles/ch1_dashboard.png)

1. If the signed-in user does not have the right privileges, clicking on the **See All Tasks** will give an error:

![error](./ReadmeFiles/ch1_error.png)

### We'd love your feedback!

> :information_source: Consider taking a moment to share [your experience with us](https://forms.office.com/Pages/ResponsePage.aspx?id=v4j5cvGGr0GRqy180BHbR73pcsbpbxNJuZCMKN0lURpUOU5PNlM4MzRRV0lETkk2ODBPT0NBTEY5MCQlQCN0PWcu)

## Troubleshooting

<details>
	<summary>Expand for troubleshooting info</summary>

Use [Stack Overflow](http://stackoverflow.com/questions/tagged/msal) to get support from the community.
Ask your questions on Stack Overflow first and browse existing issues to see if someone has asked your question before.
Make sure that your questions or comments are tagged with [`azure-active-directory` `dotnet` `ms-identity` `adal` `msal`].

If you find a bug in the sample, raise the issue on [GitHub Issues](../../../../issues).

To provide feedback on or suggest features for Azure Active Directory, visit [User Voice page](https://feedback.azure.com/forums/169401-azure-active-directory).

</details>


## About the code

### Angular RoleGuard and protected routes for role-based access control

The client application Angular SPA has a [role.guard.ts](./SPA/src/app/role.guard.ts) component that checks whether a user belongs to the required role(s) to access a protected route (see also: [base.guard.ts](./SPA/src/app/base.guard.ts)). It does this by checking `roles` claim the ID token of the signed-in user:

```typescript
@Injectable()
export class RoleGuard extends BaseGuard {

  constructor(
    @Inject(MSAL_GUARD_CONFIG) protected override msalGuardConfig: MsalGuardConfiguration,
    protected override msalBroadcastService: MsalBroadcastService,
    protected override authService: MsalService,
    protected override location: Location,
    protected override router: Router
  ) {
    super(msalGuardConfig, msalBroadcastService, authService, location, router);
  }

  override activateHelper(state?: RouterStateSnapshot, route?: ActivatedRouteSnapshot): Observable<boolean | UrlTree> {
    let result = super.activateHelper(state, route);

    const expectedRoles: string[] = route ? route.data['expectedRoles'] : [];

    return result.pipe(
      concatMap(() => {
        let activeAccount = this.authService.instance.getActiveAccount();

        if (!activeAccount && this.authService.instance.getAllAccounts().length > 0) {
            activeAccount = this.authService.instance.getAllAccounts()[0];
        }

        if (!activeAccount?.idTokenClaims?.roles) {
            window.alert('Token does not have roles claim. Please ensure that your account is assigned to an app role and then sign-out and sign-in again.');
            return of(false);
        }

        const hasRequiredRole = expectedRoles.some((role: string) => activeAccount?.idTokenClaims?.roles?.includes(role));

        if (!hasRequiredRole) {
            window.alert('You do not have access as the expected role is not found. Please ensure that your account is assigned to an app role and then sign-out and sign-in again.');
        }

        return of(hasRequiredRole);
      })
    );
  }
}
```

We then enable **RoleGuard** in [app-routing.module.ts](./SPA/src/app/app-routing.module.ts) as follows:

```typescript
const routes: Routes = [
    {
        path: 'todo-edit/:id',
        component: TodoEditComponent,
        canActivate: [
            RoleGuard
        ],
        data: {
            expectedRoles: [roles.TaskUser, roles.TaskAdmin]
        }
    },
    {
        path: 'todo-view',
        component: TodoViewComponent,
        canActivate: [
            RoleGuard
        ],
        data: {
            expectedRoles: [roles.TaskUser, roles.TaskAdmin]
        }
    },
    {
        path: 'dashboard',
        component: DashboardComponent,
        canActivate: [
            RoleGuard,
        ],
        data: {
            expectedRoles: [roles.TaskAdmin]
        }
    },
    {
        // Needed for handling redirect after login
        path: 'auth',
        component: MsalRedirectComponent
    },
    {
        path: '',
        component: HomeComponent
    }
];
```

However, it is important to be aware of that no content on a browser application is **truly** secure. That is, our **RoleGuard** component is primarily responsible for rendering the correct pages and other UI elements for a user in a particular role; in the example above, we allow only users in the `TaskAdmin` role to see the `Dashboard` component. In order to **truly** protect data and expose certain REST operations to a selected set of users, we enable **RBAC** on the back-end/web API as well in this sample. This is shown next.

### Policy based authorization for .NET Core web API

As mentioned before, in order to **truly** implement **RBAC** and secure data, this sample  allows only authorized calls to our web API. We do this by defining access policies and decorating our HTTP methods with them. To do so, we first add `roles` claim as a validation parameter in [Startup.cs](./API/TodoListAPI/Startup.cs), and then we create authorization policies that depends on this claim:

```csharp
// See https://docs.microsoft.com/aspnet/core/security/authorization/roles for more info.
services.Configure<JwtBearerOptions>(JwtBearerDefaults.AuthenticationScheme, options =>
{
    // The claim in the Jwt token where App roles are available.
    options.TokenValidationParameters.RoleClaimType = "roles";
});

// Adding authorization policies that enforce authorization using Azure AD roles.
services.AddAuthorization(options =>
{
    options.AddPolicy(AuthorizationPolicies.AssignmentToTaskUserRoleRequired, policy => policy.RequireRole(Configuration["AzureAd:Roles:TaskUser"], Configuration["AzureAd:Roles:TaskAdmin"]));

    options.AddPolicy(AuthorizationPolicies.AssignmentToTaskAdminRoleRequired, policy => policy.RequireRole(Configuration["AzureAd:Roles:TaskAdmin"]));
});
```

We defined these roles in [appsettings.json](./API/TodoListAPI/appsettings.json) as follows:

```json
"Roles": {
    "TaskAdmin": "TaskAdmin",
    "TaskUser": "TaskUser"
}
```

Finally, in [TodoListController.cs](./API/TodoListAPI/Controllers/TodoListController.cs), we decorate our routes with the appropriate policy:

```csharp
// GET: api/todolist/getAll
[HttpGet]
[Route("getAll")]
[RequiredScope(RequiredScopesConfigurationKey = "AzureAd:Scopes")]
[Authorize(Policy = AuthorizationPolicies.AssignmentToTaskAdminRoleRequired)]
public async Task<ActionResult<IEnumerable<TodoItem>>> GetAll()
{
    return await _context.TodoItems.ToListAsync();
}

// GET: api/TodoItems
[HttpGet]
[RequiredScope(RequiredScopesConfigurationKey = "AzureAd:Scopes")]
[Authorize(Policy = AuthorizationPolicies.AssignmentToTaskUserRoleRequired)]
public async Task<ActionResult<IEnumerable<TodoItem>>> GetTodoItems()
{
    return await _context.TodoItems.Where(x => x.Owner == HttpContext.User.GetObjectId()).ToListAsync();
}
```

## Next Steps

Learn how to [Protect and call an API using Security Groups](../../5-AccessControl/2-call-api-groups/README.md).

## Contributing

If you'd like to contribute to this sample, see [CONTRIBUTING.MD](/CONTRIBUTING.md).

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information, see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Learn More

* [Microsoft identity platform (Azure Active Directory for developers)](https://docs.microsoft.com/azure/active-directory/develop/)
* [Overview of Microsoft Authentication Library (MSAL)](https://docs.microsoft.com/azure/active-directory/develop/msal-overview)
* [Register an application with the Microsoft identity platform](https://docs.microsoft.com/azure/active-directory/develop/quickstart-register-app)
* [Configure a client application to access web APIs](https://docs.microsoft.com/azure/active-directory/develop/quickstart-configure-app-access-web-apis)
* [Understanding Azure AD application consent experiences](https://docs.microsoft.com/azure/active-directory/develop/application-consent-experience)
* [Understand user and admin consent](https://docs.microsoft.com/azure/active-directory/develop/howto-convert-app-to-be-multi-tenant#understand-user-and-admin-consent)
* [Application and service principal objects in Azure Active Directory](https://docs.microsoft.com/azure/active-directory/develop/app-objects-and-service-principals)
* [Authentication Scenarios for Azure AD](https://docs.microsoft.com/azure/active-directory/develop/authentication-flows-app-scenarios)
* [Building Zero Trust ready apps](https://aka.ms/ztdevsession)
* [National Clouds](https://docs.microsoft.com/azure/active-directory/develop/authentication-national-cloud#app-registration-endpoints)
* [Azure AD code samples](https://docs.microsoft.com/azure/active-directory/develop/sample-v2-code)
* [Microsoft.Identity.Web](https://aka.ms/microsoft-identity-web)