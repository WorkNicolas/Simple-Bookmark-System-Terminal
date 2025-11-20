# --- Directory bookmarks for PowerShell ---
$Global:BookmarkFile = Join-Path $HOME ".dir_bookmarks"

function bookmark {
    param(
        [Parameter(Position = 0)]
        [string]$Arg1,
        [Parameter(Position = 1)]
        [string]$Arg2
    )

    if (-not (Test-Path $Global:BookmarkFile)) {
        New-Item -ItemType File -Path $Global:BookmarkFile -Force | Out-Null
    }

    # bookmark ls
    if ($Arg1 -eq "ls") {
        $titles = @()
        foreach ($line in Get-Content $Global:BookmarkFile) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            $parts = $line -split '\|', 2
            if ($parts[0]) { $titles += $parts[0] }
        }

        if ($titles.Count -gt 0) {
            # one title per line, like the Bash/zsh versions
            $titles | ForEach-Object { Write-Output $_ }
        }

        return
    }

    # bookmark rm <name>
    if ($Arg1 -eq "rm") {
        $name = $Arg2
        if (-not $name) {
            Write-Host "[ERROR] - missing bookmark name"
            return
        }

        $found = $false
        $newLines = @()

        foreach ($line in Get-Content $Global:BookmarkFile) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            $parts = $line -split '\|', 2
            $title = $parts[0]
            $path  = $parts[1]

            if ($title -eq $name) {
                $found = $true
                continue
            }

            $newLines += "$title|$path"
        }

        # Rewrite file (or clear if no lines left)
        if ($newLines.Count -gt 0) {
            $newLines | Set-Content $Global:BookmarkFile
        } else {
            # keep file existing but empty
            '' | Set-Content $Global:BookmarkFile
        }

        if ($found) {
            Write-Host "[SUCCESS] - $name removed"
        } else {
            Write-Host "[ERROR] - $name doesn't exist"
        }
        return
    }

    # Determine path to bookmark
    $path = $null
    if (-not $Arg1) {
        # bookmark       -> current directory
        $path = (Get-Location).Path
    } else {
        $path = $Arg1
    }

    # If Arg1 is a directory path, create a bookmark
    if (Test-Path -LiteralPath $path -PathType Container) {
        # Use fully-qualified Resolve-Path to ignore aliases/wrapper functions
        $fullPath = (Microsoft.PowerShell.Management\Resolve-Path -LiteralPath $path).Path

        while ($true) {
            Write-Host -NoNewLine "[Bookmark Title]: "
            $title = Read-Host

            if ($title -match '\s') {
                Write-Host "[ERROR] - bookmark $title has spaces"
                continue
            }

            if (-not $title) {
                continue
            }

            $exists = $false
            foreach ($line in Get-Content $Global:BookmarkFile) {
                if ([string]::IsNullOrWhiteSpace($line)) { continue }
                $parts = $line -split '\|', 2
                if ($parts[0] -eq $title) {
                    $exists = $true
                    break
                }
            }

            if ($exists) {
                Write-Host "[ERROR] - bookmark $title already exists"
                continue
            }

            "$title|$fullPath" | Add-Content $Global:BookmarkFile
            Write-Host "[SUCCESS] - bookmark $title has been created"
            break
        }

        return
    }

    # Otherwise, treat Arg1 as a bookmark title to jump to
    $wantedTitle = $Arg1
    $dest = $null

    foreach ($line in Get-Content $Global:BookmarkFile) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $parts = $line -split '\|', 2
        if ($parts[0] -eq $wantedTitle) {
            $dest = $parts[1]
            break
        }
    }

    if (-not $dest) {
        Write-Host "[ERROR] - $wantedTitle doesn't exist"
        return
    }

    if (-not (Test-Path -LiteralPath $dest -PathType Container)) {
        Write-Host "[ERROR] - failed to cd into $dest"
        return
    }

    # Use fully-qualified Set-Location (like builtin cd)
    Microsoft.PowerShell.Management\Set-Location -LiteralPath $dest
}

Set-Alias bm bookmark
