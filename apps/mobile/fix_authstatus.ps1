$files = Get-ChildItem -Recurse -Filter *.dart -Path lib | Where-Object { $_ | Select-String 'AuthStatus\.(initial|unauthenticated|loading|authenticated|verificationPending|mfaRequired|mfaEnrollment|mfaChallenge|failure)\(\)' }
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $content = $content -replace 'AuthStatus\.initial\(\)', 'AuthStatus.initial'
    $content = $content -replace 'AuthStatus\.unauthenticated\(\)', 'AuthStatus.unauthenticated'
    $content = $content -replace 'AuthStatus\.loading\(\)', 'AuthStatus.loading'
    $content = $content -replace 'AuthStatus\.authenticated\(\)', 'AuthStatus.authenticated'
    $content = $content -replace 'AuthStatus\.verificationPending\(\)', 'AuthStatus.verificationPending'
    $content = $content -replace 'AuthStatus\.mfaRequired\(\)', 'AuthStatus.mfaRequired'
    $content = $content -replace 'AuthStatus\.mfaEnrollment\(\)', 'AuthStatus.mfaEnrollment'
    $content = $content -replace 'AuthStatus\.mfaChallenge\(\)', 'AuthStatus.mfaChallenge'
    $content = $content -replace 'AuthStatus\.failure\(\)', 'AuthStatus.failure'
    $content = $content -replace 'const AuthStatus\.initial', 'AuthStatus.initial'
    $content = $content -replace 'const AuthStatus\.unauthenticated', 'AuthStatus.unauthenticated'
    $content = $content -replace 'const AuthStatus\.loading', 'AuthStatus.loading'
    $content = $content -replace 'const AuthStatus\.authenticated', 'AuthStatus.authenticated'
    $content = $content -replace 'const AuthStatus\.verificationPending', 'AuthStatus.verificationPending'
    $content = $content -replace 'const AuthStatus\.mfaRequired', 'AuthStatus.mfaRequired'
    $content = $content -replace 'const AuthStatus\.mfaEnrollment', 'AuthStatus.mfaEnrollment'
    $content = $content -replace 'const AuthStatus\.mfaChallenge', 'AuthStatus.mfaChallenge'
    $content = $content -replace 'const AuthStatus\.failure', 'AuthStatus.failure'
    Set-Content $file.FullName $content
    Write-Host "Fixed: $($file.FullName)"
}