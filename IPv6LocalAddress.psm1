data Resources {
    ConvertFrom-StringData -StringData @'
    NotMacAddress = The address '{0}' is not a MAC address.
'@
}

#region variables
$LocalAddressPrefix = [byte[]]@(0xFD)
$NtpEpochTime = [datetime]::new(1900, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)
#endregion

function ConvertTo-IPv6InterfaceId {
    [CmdletBinding(
        HelpUri = "https://github.com/takakiwakuda/IPv6LocalAddress/docs/ConvertTo-IPv6InterfaceId.md")]
    [OutputType([PhysicalAddress])]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [PhysicalAddress]
        $MacAddress
    )

    process {
        GetInterfaceId $MacAddress
    }
}

function New-IPv6LocalAddress {
    [CmdletBinding(
        HelpUri = "https://github.com/takakiwakuda/IPv6LocalAddress/docs/New-IPv6LocalAddress.md")]
    [OutputType([ipaddress])]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [PhysicalAddress]
        $MacAddress,

        [Parameter()]
        [UInt16]
        $SubnetId,

        [Parameter()]
        [UInt32]
        $ScopeId
    )

    begin {
        $dateTime = [datetime]::UtcNow
        $timestamp = GetNtpTimestamp $dateTime
    }
    process {
        $interfaceId = GetInterfaceId $MacAddress
        $globalId = GetGlobalId $timestamp $interfaceId

        GetIPv6LocalAddress $globalId $interfaceId $SubnetId $ScopeId
    }
}

#region utility functions
function GetGlobalId {
    [OutputType([byte[]])]
    param (
        [UInt64]
        $Timestamp,

        [PhysicalAddress]
        $InterfaceId
    )

    $timestampBytes = [System.BitConverter]::GetBytes($Timestamp)
    if ([System.BitConverter]::IsLittleEndian) {
        [array]::Reverse($timestampBytes)
    }

    $addressBytes = $InterfaceId.GetAddressBytes()
    $buffer = [byte[]]::new($timestampBytes.Length + $addressBytes.Length)

    [System.Buffer]::BlockCopy($timestampBytes, 0, $buffer, 0, $timestampBytes.Length)
    [System.Buffer]::BlockCopy($addressBytes, 0, $buffer, $timestampBytes.Length, $addressBytes.Length)

    $sha = [System.Security.Cryptography.SHA1CryptoServiceProvider]::new()
    $globalId = [byte[]]::new(5)

    try {
        [System.Buffer]::BlockCopy($sha.ComputeHash($buffer), 15, $globalId, 0, $globalId.Length)
    }
    finally {
        $sha.Dispose()
    }

    $globalId
}

function GetInterfaceId {
    [OutputType([PhysicalAddress])]
    param (
        [PhysicalAddress]
        $MacAddress
    )

    ValidateMacAddress $MacAddress

    $addressBytes = $MacAddress.GetAddressBytes()
    $buffer = [byte[]]::new(8)
    $buffer[0] = $addressBytes[0] -bxor 0x2
    $buffer[3] = 0xFF
    $buffer[4] = 0xFE
    [System.Buffer]::BlockCopy($addressBytes, 1, $buffer, 1, 2)
    [System.Buffer]::BlockCopy($addressBytes, 3, $buffer, 5, 3)

    [PhysicalAddress]::new($buffer)
}

function GetIPv6LocalAddress {
    [OutputType([ipaddress])]
    param (
        [byte[]]
        $GlobalId,

        [PhysicalAddress]
        $InterfaceId,

        [UInt16]
        $SubnetId,

        [UInt32]
        $ScopeId
    )

    $subnetIdBytes = [System.BitConverter]::GetBytes($SubnetId)
    if ([System.BitConverter]::IsLittleEndian) {
        [array]::Reverse($subnetIdBytes)
    }

    $addressBytes = $InterfaceId.GetAddressBytes()
    $buffer = [byte[]]::new(16)
    $offset = 0

    [System.Buffer]::BlockCopy($LocalAddressPrefix, 0, $buffer, $offset, $LocalAddressPrefix.Length)
    $offset += $LocalAddressPrefix.Length
    [System.Buffer]::BlockCopy($GlobalId, 0, $buffer, $offset, $GlobalId.Length)
    $offset += $GlobalId.Length
    [System.Buffer]::BlockCopy($subnetIdBytes, 0, $buffer, $offset, $subnetIdBytes.Length)
    $offset += $subnetIdBytes.Length
    [System.Buffer]::BlockCopy($addressBytes, 0, $buffer, $offset, $addressBytes.Length)

    [ipaddress]::new($buffer, $ScopeId)
}

function GetNtpTimestamp {
    [OutputType([UInt64])]
    param (
        [datetime]
        $DateTime
    )

    $ticks = $DateTime.Ticks - $NtpEpochTime.Ticks
    $seconds = $ticks / [timespan]::TicksPerSecond
    $fraction = (($ticks % [timespan]::TicksPerSecond) * 0x100000000L) / [timespan]::TicksPerSecond
    [UInt64]$seconds -shl 32 -bor $fraction
}

function ValidateMacAddress {
    param (
        [PhysicalAddress]
        $MacAddress
    )

    $addressBytes = $MacAddress.GetAddressBytes()

    if ($addressBytes.Length -ne 6) {
        $errorMessage = $Resources.NotMacAddress -f [System.BitConverter]::ToString($addressBytes)
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            [System.InvalidOperationException]::new($errorMessage),
            "NotMacAddress",
            [System.Management.Automation.ErrorCategory]::InvalidArgument,
            $MacAddress)

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
}
#endregion

Export-ModuleMember -Function "ConvertTo-IPv6InterfaceId", "New-IPv6LocalAddress"
