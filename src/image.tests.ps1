#
# Functions
#

# Run commands in a container and return.
function Invoke-Container([string[]]$DockerParameters, [string[]]$ImageParameters) {
    $allParameters = @('run', '--rm'; $DockerParameters; $env:FULL_IMAGE_NAME)
    if ($ImageParameters) {
        # Do not add a $null as last parameter if $ImageParameters is empty
        $allParameters += $ImageParameters
    }

    Write-Verbose "docker $allParameters"
    docker $allParameters
}

# Run commands in a detached container.
function Use-Container([string[]]$Parameters, [Parameter(Mandatory)][ScriptBlock]$ScriptBlock) {
    $allParameters = @('run'; $Parameters; '--detach', $env:FULL_IMAGE_NAME)

    Write-Verbose "docker $allParameters"
    $cId = docker $allParameters
    try {
        Start-Sleep -Seconds 0.5    # Wait for container initializaion
        Invoke-Command $ScriptBlock -ArgumentList $cId
    }
    finally {
        docker rm --force $cId > $null
    }
}

# Asserts that InputValue contains at least one occurence of Pattern.
function Contains([Parameter(ValueFromPipeline)]$InputValue, [string[]]$Pattern) {
    process {
        if ($hasMatch) { return; }
        $_matches = $InputValue | Select-String -Pattern $Pattern
        $hasMatch = $null -ne $_matches
    }

    end {
        assert $hasMatch
    }
}

# Asserts that InputValue contains exactly ExpectedCount occurences of Pattern.
function ContainsExactly([Parameter(ValueFromPipeline)]$InputValue, [string[]]$Pattern, [int]$ExpectedCount) {
    process {
        $_matches = $InputValue | Select-String -Pattern $Pattern
        $totalMatches += $_matches.Count
    }

    end {
        assert ($totalMatches -eq $ExpectedCount)
    }
}

# Asserts that LastExitCode is equal to ExpectedValue.
function ExitCodeIs ([Parameter(ValueFromPipeline)]$InputValue, [int]$ExpectedValue) {
    process { }
    end {
        assert ($LastExitCode -eq $ExpectedValue)
    }
}



#
# Tests
#

task With_command_should_not_start_Firebird {
    Invoke-Container -ImageParameters 'ps', '-A' |
        ContainsExactly -Pattern 'firebird|fbguard' -ExpectedCount 0
}

task Without_command_should_start_Firebird {
    Use-Container -ScriptBlock {
        param($cId)

        # Both firebird and fbguard must be running
        docker exec $cId ps -A |
            ContainsExactly -Pattern 'firebird|fbguard' -ExpectedCount 2

        # "Starting" but no "Stopping"
        docker logs $cId |
            ContainsExactly -Pattern 'Starting Firebird|Stopping Firebird' -ExpectedCount 1

        # Stop
        docker stop $cId > $null

        # "Starting" and "Stopping"
        docker logs $cId |
            ContainsExactly -Pattern 'Starting Firebird|Stopping Firebird' -ExpectedCount 2
    }
}

task ISC_PASSWORD_can_change_sysdba_password {
    Use-Container -Parameters '--rm', '-e', 'ISC_PASSWORD=passw0rd' {
        param($cId)

        docker exec $cId cat /opt/firebird/SYSDBA.password |
            ContainsExactly -Pattern 'passw0rd' -ExpectedCount 2

        docker logs $cId |
            Contains -Pattern 'Changing SYSDBA password'
    }
}

task FIREBIRD_ROOT_PASSWORD_can_change_sysdba_password {
    Use-Container -Parameters '--rm', '-e', 'FIREBIRD_ROOT_PASSWORD=passw0rd' {
        param($cId)

        docker exec $cId cat /opt/firebird/SYSDBA.password |
            ContainsExactly -Pattern 'passw0rd' -ExpectedCount 2

        docker logs $cId |
            Contains -Pattern 'Changing SYSDBA password'
    }
}

task FIREBIRD_DATABASE_can_create_database {
    Use-Container -Parameters '--rm', '-e', 'FIREBIRD_DATABASE=test.fdb' {
        param($cId)

        docker exec $cId test -f /run/firebird/data/test.fdb |
            ExitCodeIs -ExpectedValue 0

        docker logs $cId |
            Contains -Pattern "Creating database '/run/firebird/data/test.fdb'"
    }
}

task FIREBIRD_DATABASE_can_create_database_with_absolute_path {
    Use-Container -Parameters '--rm', '-e', 'FIREBIRD_DATABASE=/tmp/test.fdb' {
        param($cId)

        docker exec $cId test -f /tmp/test.fdb |
            ExitCodeIs -ExpectedValue 0

        docker logs $cId |
            Contains -Pattern "Creating database '/tmp/test.fdb'"
    }
}

task FIREBIRD_DATABASE_PAGE_SIZE_can_set_page_size_on_database_creation {
    Use-Container -Parameters '--rm', '-e', 'FIREBIRD_DATABASE=test.fdb', '-e', 'FIREBIRD_DATABASE_PAGE_SIZE=4096' {
        param($cId)

        'SET BAIL ON; SET LIST ON; SELECT mon$page_size FROM mon$database;' |
            docker exec -i $cId isql -q /run/firebird/data/test.fdb |
                Contains -Pattern 'MON\$PAGE_SIZE(\s+)4096'
    }

    Use-Container -Parameters '--rm', '-e', 'FIREBIRD_DATABASE=test.fdb', '-e', 'FIREBIRD_DATABASE_PAGE_SIZE=16384' {
        param($cId)

        'SET BAIL ON; SET LIST ON; SELECT mon$page_size FROM mon$database;' |
            docker exec -i $cId isql -q /run/firebird/data/test.fdb |
                Contains -Pattern 'MON\$PAGE_SIZE(\s+)16384'
    }
}

task FIREBIRD_DATABASE_DEFAULT_CHARSET_can_set_default_charset_on_database_creation {
    Use-Container -Parameters '--rm', '-e', 'FIREBIRD_DATABASE=test.fdb' {
        param($cId)

        'SET BAIL ON; SET LIST ON; SELECT rdb$character_set_name FROM rdb$database;' |
            docker exec -i $cId isql -q /run/firebird/data/test.fdb |
                Contains -Pattern 'RDB\$CHARACTER_SET_NAME(\s+)NONE'
    }

    Use-Container -Parameters '--rm', '-e', 'FIREBIRD_DATABASE=test.fdb', '-e', 'FIREBIRD_DATABASE_DEFAULT_CHARSET=UTF8' {
        param($cId)

        'SET BAIL ON; SET LIST ON; SELECT rdb$character_set_name FROM rdb$database;' |
            docker exec -i $cId isql -q /run/firebird/data/test.fdb |
                Contains -Pattern 'RDB\$CHARACTER_SET_NAME(\s+)UTF8'
    }
}

task FIREBIRD_USER_fails_without_password {
    # Captures both stdout and stderr
    $($stdout = Invoke-Container -DockerParameters '-e', 'FIREBIRD_USER=alice') 2>&1 |
        Contains -Pattern 'FIREBIRD_PASSWORD variable is not set.'    # stderr

    assert ($stdout -eq $null)
}

task FIREBIRD_USER_can_create_user {
    Use-Container -Parameters '--rm', '-e', 'FIREBIRD_DATABASE=test.fdb', '-e', 'FIREBIRD_USER=alice', '-e', 'FIREBIRD_PASSWORD=bird' {
        param($cId)

        # Use 'SET BAIL ON' for isql to return exit codes.
        # USe 'inet://' protocol to not connect directly to database (skipping authentication)

        # Correct password
        'SET BAIL ON; SELECT 1 FROM rdb$database;' |
            docker exec -i $cId isql -q -u alice -p bird inet:///run/firebird/data/test.fdb |
                ExitCodeIs -ExpectedValue 0

        # Incorrect password
        'SET BAIL ON; SELECT 1 FROM rdb$database;' |
            docker exec -i $cId isql -q -u alice -p tiger inet:///run/firebird/data/test.fdb 2>&1 |
                ExitCodeIs -ExpectedValue 1

        docker logs $cId |
            Contains -Pattern "Creating user 'alice'"
    }
}

task FIREBIRD_USE_LEGACY_AUTH_enables_legacy_auth {
    Use-Container -Parameters '--rm', '-e', 'FIREBIRD_USE_LEGACY_AUTH=true' {
        param($cId)

        $logs = docker logs $cId
        $logs | Contains -Pattern "Using Legacy_Auth"
        $logs | Contains -Pattern "AuthServer = Legacy_Auth"
        $logs | Contains -Pattern "AuthClient = Legacy_Auth"
        $logs | Contains -Pattern "WireCrypt = Enabled"
    }
}

task FIREBIRD_CONF_can_change_any_setting {
    Use-Container -Parameters '--rm', '-e', 'FIREBIRD_CONF_DefaultDbCachePages=64K', '-e', 'FIREBIRD_CONF_DefaultDbCachePages=64K', '-e', 'FIREBIRD_CONF_FileSystemCacheThreshold=100M' {
        param($cId)

        $logs = docker logs $cId
        $logs | Contains -Pattern "DefaultDbCachePages = 64K"
        $logs | Contains -Pattern "FileSystemCacheThreshold = 100M"
    }
}

task FIREBIRD_CONF_key_is_case_sensitive {
    Use-Container -Parameters '--rm', '-e', 'FIREBIRD_CONF_WireCrypt=Disabled' {
        param($cId)

        $logs = docker logs $cId
        $logs | Contains -Pattern "WireCrypt = Disabled"
    }

    Use-Container -Parameters '--rm', '-e', 'FIREBIRD_CONF_WIRECRYPT=Disabled' {
        param($cId)

        $logs = docker logs $cId
        $logs | ContainsExactly -Pattern "WireCrypt = Disabled" -ExpectedCount 0
    }
}
