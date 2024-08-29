#
# Globals
#

$outputFolder = './generated'

$defaultVariant = 'bookworm'

$blockedVariants = @{'3' = @('noble') }    # Ubuntu 24.04 doesn't have libncurses5.



#
# Functions
#

function Expand-Template([Parameter(ValueFromPipeline = $true)]$Template) {
    $evaluator = {
        $innerTemplate = $args[0].Groups[1].Value
        $ExecutionContext.InvokeCommand.ExpandString($innerTemplate)
    }
    $regex = [regex]"\<\%(.*?)\%\>"
    $regex.Replace($Template, $evaluator)
}

function Copy-TemplateItem([string]$Path, [string]$Destination, [switch]$Force) {
    if (Test-Path $Destination) {
        # File already exists. 

        if ($Force) {
            # With -Force: Overwrite.
            $outputFile = Get-Item $Destination
            $outputFile.Attributes -= 'ReadOnly'
        } else {
            # Without -Force: Nothing to do.
            return
        }
    }


    if ( (-not $Force) -and (Test-Path $Destination) ) {
        # File already exists. Ignore.
        return
    }

    # Add header
    $fileExtension = $Destination.Split('.')[-1]
    $header = if ($fileExtension -eq 'md') {
        @'

[//]: # (This file was auto-generated. Do not edit. See /src.)

'@
    } else {
        @'
#
# This file was auto-generated. Do not edit. See /src.
#

'@
    }
    $header | Set-Content $Destination -Encoding UTF8

    # Expand template
    Get-Content $Path -Raw -Encoding UTF8 |
        Expand-Template |
            Add-Content $Destination -Encoding UTF8

    # Set readonly flag (another reminder to not edit the file)
    $outputFile = Get-Item $Destination
    $outputFile.Attributes += 'ReadOnly'
}

function Use-CachedResponse {
    param(
        [Parameter(Mandatory = $true)]
        [string]$JsonFile,

        [scriptblock]$ScriptBlock
    )

    if (Test-Path $JsonFile) {
        return Get-Content $JsonFile | ConvertFrom-Json
    }

    $result = Invoke-Command -ScriptBlock $ScriptBlock
    return $result | ConvertTo-Json -Depth 10 | Out-File $JsonFile -Encoding utf8
}



#
# Tasks
#

# Synopsis: Rebuild "assets.json" from GitHub releases.
task Update-Assets {
    $tempFolder = [System.IO.Path]::GetTempPath()

    $releasesFile = Join-Path $tempFolder 'github-releases.json'
    $assetsFolder = Join-Path $tempFolder 'firebird-assets'
    New-Item $assetsFolder -ItemType Directory -Force > $null

    # All github releases
    $releases = Use-CachedResponse -JsonFile $releasesFile { Invoke-RestMethod -Uri "https://api.github.com/repos/FirebirdSQL/firebird/releases" -UseBasicParsing }

    # Ignore legacy and prerelease
    $currentReleases = $releases | Where-Object { ($_.tag_name -like 'v*') -and (-not $_.prerelease) }

    # Select only amd64 and non-debug assets
    $currentAssets = $currentReleases |
        Select-Object -Property @{ Name='version'; Expression={ [version]$_.tag_name.TrimStart("v") } },
                                @{ Name='download_url'; Expression={ $_.assets.browser_download_url | Where-Object { ( $_ -like '*amd64*' -or $_ -like '*linux-x64*') -and ($_ -notlike '*debug*') } } } |
        Sort-Object -Property version -Descending

    # Group by major version
    $groupedAssets = $currentAssets |
        Select-Object -Property @{ Name='major'; Expression={ $_.version.Major } }, 'version', 'download_url' |
        Group-Object -Property 'major'

    # Get Variants
    $dockerFiles = Get-Item './src/Dockerfile.*.template'
    $allOtherVariants = $dockerFiles.Name |
        Select-String -Pattern 'Dockerfile.(.+).template' |
        ForEach-Object { $_.Matches.Groups[1].Value } |
        Where-Object { $_ -ne $defaultVariant }
    $allVariants = @($defaultVariant) + $otherVariants

    # For each asset
    $groupedAssets | ForEach-Object -Begin { $groupIndex = 0 } -Process {
        # For each major version
        $_.Group | ForEach-Object -Begin { $index = 0 } -Process {
            $asset = $_

            # Remove blocked variants

            $otherVariants = $allOtherVariants | Where-Object { $_ -notin $blockedVariants."$($asset.major)" }
            $variants = $allVariants | Where-Object { $_ -notin $blockedVariants."$($asset.major)" }

            $assetFileName = ([uri]$asset.download_url).Segments[-1]
            $assetLocalFile = Join-Path $assetsFolder $assetFileName
            if (-not (Test-Path $assetLocalFile)) {
                $ProgressPreference = 'SilentlyContinue'    # How NOT to implement a progress bar -- https://stackoverflow.com/a/43477248
                Invoke-WebRequest $asset.download_url -OutFile $assetLocalFile
            }

            $sha256 = Get-FileHash $assetLocalFile -Algorithm SHA256

            $tags = [ordered]@{}

            $tags[$defaultVariant] = @("$($asset.version)")
            $otherVariants | ForEach-Object {
                $tags[$_] = @("$($asset.version)-$_")
            }

            if ($index -eq 0) {
                # latest of this major version
                $tags[$defaultVariant] = @("$($asset.major)") + $tags[$defaultVariant]
                $otherVariants | ForEach-Object {
                    $tags[$_] = @("$($asset.major)-$_") + $tags[$_]
                }
            }

            if (($groupIndex -eq 0) -and ($index -eq 0)) {
                # latest of all
                $variants | ForEach-Object {
                    $tags[$_] = @("$_") + $tags[$_]
                }
            }

            Write-Output ([ordered]@{
                'version' = "$($asset.version)"
                'url' = $asset.download_url
                'sha256' = $sha256.Hash.ToLower()
                'tags' = $tags
            })

            $index++
        }
        $groupIndex++
    } | ConvertTo-Json -Depth 10 | Out-File './assets.json' -Encoding ascii
}

# Synopsis: Rebuild "README.md" from "assets.json".
task Update-Readme {
    # For each asset
    $assets = Get-Content -Raw -Path '.\assets.json' | ConvertFrom-Json 
    $TSupportedTags = $assets | ForEach-Object {
        $asset = $_

        $version = [version]$asset.version
        $versionFolder = Join-Path $outputFolder $version

        # For each image
        $asset.tags | Get-Member -MemberType NoteProperty | ForEach-Object {
            $image = $_.Name

            $TImageTags = $asset.tags.$image
            if ($TImageTags) {
                # https://stackoverflow.com/a/73073678
                $TImageTags = "``{0}``" -f ($TImageTags -join "``, ``")
            }

            $variantFolder = (Join-Path $versionFolder $image).Replace('\', '/')

            Write-Output "|$TImageTags|[Dockerfile]($variantFolder/Dockerfile)|`n"
        }
    }

    Copy-TemplateItem "./src/README.md.template" './README.md' -Force
}

# Synopsis: Invoke preprocessor to generate images sources from "assets.json".
task Prepare {
    # Clear/create output folder
    Remove-Item -Path $outputFolder -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory $outputFolder -Force > $null

    # For each asset
    $assets = Get-Content -Raw -Path '.\assets.json' | ConvertFrom-Json 
    $assets | ForEach-Object {
        $asset = $_

        $version = [version]$asset.version
        $versionFolder = Join-Path $outputFolder $version
        New-Item -ItemType Directory $versionFolder -Force > $null

        # For each image
        $asset.tags | Get-Member -MemberType NoteProperty | ForEach-Object {
            $image = $_.Name

            $TUrl = $asset.url
            $TSha256 = $asset.sha256
            $TMajor = $version.Major
            $TImageVersion = $version

            $TImageTags = $asset.tags.$image
            if ($TImageTags) {
                # https://stackoverflow.com/a/73073678
                $TImageTags = "'{0}'" -f ($TImageTags -join "', '")
            }

            $variantFolder = Join-Path $versionFolder $image
            New-Item -ItemType Directory $variantFolder -Force > $null

            Copy-TemplateItem "./src/Dockerfile.$image.template" "$variantFolder/Dockerfile"
            Copy-Item './src/entrypoint.sh' $variantFolder
            Copy-TemplateItem "./src/image.build.ps1.template" "$variantFolder/image.build.ps1"
            Copy-Item './src/image.tests.ps1' $variantFolder
        }
    }
}

# Synopsis: Build all docker images.
task Build Prepare, {
    $builds = Get-ChildItem "$outputFolder/**/image.build.ps1" -Recurse | ForEach-Object {
        @{File = $_; Task = 'Build' }
    }
    Build-Parallel $builds
}

# Synopsis: Run all tests.
task Test {
    $builds = Get-ChildItem "$outputFolder/**/image.build.ps1" -Recurse | ForEach-Object {
        @{File = $_; Task = 'Test' }
    }
    Build-Parallel $builds
}

# Synopsis: Publish all images.
task Publish {
    $builds = Get-ChildItem "$outputFolder/**/image.build.ps1" -Recurse | ForEach-Object {
        @{File = $_; Task = 'Publish' }
    }
    Build-Parallel $builds
}

# Synopsis: Default task.
task . Build
