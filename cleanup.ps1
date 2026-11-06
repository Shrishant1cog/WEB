$items = Get-ChildItem -LiteralPath 'C:\Users\hosam\Desktop\Shri\FFT\apps\web\src\app'
foreach ($item in $items) {
    if ($item.Name -like '(admin*' -or $item.Name -like '(auth*' -or $item.Name -like '(player*' -or $item.Name -like '(public*') {
        Remove-Item -LiteralPath $item.FullName -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Removed: $($item.FullName)"
    }
}