# TOPdesk-Task-SA-Target-TOPdesk-OperatorUpdate
###########################################################
# Form mapping
$formObject = @{
    surName          = $form.surname
    prefixes         = $form.prefixes
    firstName        = $form.firstName
    firstInitials    = $form.firstInitials
    gender           = $form.gender

    telephone        = $form.telephone
    mobileNumber     = $form.mobileNumber

    employeeNumber   = $form.employeeNumber
    email            = $form.email
    networkLoginName = $form.networkLoginName
    loginName        = $form.loginName

    jobTitle         = $form.jobTitle
    branch           = $form.branch
    department       = $form.department
    
    loginPermission  = $form.loginPermission
    exchangeAccount  = $form.exchangeAccount
}
$userId = $form.id
$userDisplayName = $formObject.surName + ", " + $formObject.firstName + " " + $formObject.prefixes

try {
    Write-Information "Executing TOPdesk action: [UpdateOperatorAccount] for: [$($userDisplayName)]"
    Write-Verbose "Creating authorization headers"
    # Create authorization headers with TOPdesk API key
    $pair = "${topdeskApiUsername}:${topdeskApiSecret}"
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $key = "Basic $base64"
    $headers = @{
        "authorization" = $Key
        "Accept"        = "application/json"
    }

    Write-Verbose "Updating TOPdesk Operator for: [$($userDisplayName)]"
    $splatUpdateUserParams = @{
        Uri         = "$($topdeskBaseUrl)/tas/api/operators/id/$($userId)"
        Method      = "PATCH"
        Body        = ([System.Text.Encoding]::UTF8.GetBytes(($formObject | ConvertTo-Json -Depth 10)))
        Verbose     = $false
        Headers     = $headers
        ContentType = "application/json; charset=utf-8"
    }
    $response = Invoke-RestMethod @splatUpdateUserParams

    $auditLog = @{
        Action            = "UpdateAccount"
        System            = "TOPdesk"
        TargetIdentifier  = [String]$response.id
        TargetDisplayName = [String]$response.dynamicName
        Message           = "TOPdesk action: [UpdateOperatorAccount] for: [$($userDisplayName)] executed successfully"
        IsError           = $false
    }
    Write-Information -Tags "Audit" -MessageData $auditLog

    Write-Information "TOPdesk action: [UpdateOperatorAccount] for: [$($userDisplayName)] executed successfully"
}
catch {
    $ex = $_
    $auditLog = @{
        Action            = "UpdateAccount"
        System            = "TOPdesk"
        TargetIdentifier  = ""
        TargetDisplayName = [String]$userDisplayName
        Message           = "Could not execute TOPdesk action: [UpdateOperatorAccount] for: [$($userDisplayName)], error: $($ex.Exception.Message)"
        IsError           = $true
    }
    if ($($ex.Exception.GetType().FullName -eq "Microsoft.PowerShell.Commands.HttpResponseException")) {
        $auditLog.Message = "Could not execute TOPdesk action: [UpdateOperatorAccount] for: [$($userDisplayName)]"
        Write-Error "Could not execute TOPdesk action: [UpdateOperatorAccount] for: [$($userDisplayName)], error: $($ex.ErrorDetails)"
    }
    Write-Information -Tags "Audit" -MessageData $auditLog
    Write-Error "Could not execute TOPdesk action: [UpdateOperatorAccount] for: [$($userDisplayName)], error: $($ex.Exception.Message)"
}
###########################################################