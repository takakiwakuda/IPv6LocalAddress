$ModuleRoot = Split-Path -LiteralPath $PSScriptRoot -Resolve

Import-Module -Name $ModuleRoot -Force

Describe "New-IPv6LocalAddress" {
    BeforeAll {
        $macAddress = [PhysicalAddress]::Parse("0022446688AA")
        $notMacAddress = [PhysicalAddress]::Parse("00224466")
        $scopeId = [UInt32]::MaxValue
        $subnetId = [UInt16]::MaxValue

        function GetIPAddressCompositionObjects {
            param (
                [ipaddress]
                $IPAddress
            )

            $addressBytes = $IPAddress.GetAddressBytes()
            $iid = [PhysicalAddress]::new($addressBytes[8..15])

            # Returns MAC Address, Subnet ID, Scope ID
            (GetMacAddress $iid), ([ushort]$addressBytes[6] -shl 8 -bor $addressBytes[7]), $IPAddress.ScopeId
        }

        function GetMacAddress {
            [OutputType([PhysicalAddress])]
            param (
                [PhysicalAddress]
                $PhysicalAddress
            )

            $addressBytes = $PhysicalAddress.GetAddressBytes()
            if ($addressBytes.Length -ne 8) {
                throw "The address '{0}' is not a Interface ID." -f [System.BitConverter]::ToString($addressBytes)
            }

            $buffer = [byte[]]::new(6)
            $buffer[0] = $addressBytes[0] -bxor 0x2
            [System.Buffer]::BlockCopy($addressBytes, 1, $buffer, 1, 2)
            [System.Buffer]::BlockCopy($addressBytes, 5, $buffer, 3, 3)

            [PhysicalAddress]::new($buffer)
        }
    }

    Context "Errors" {
        It "Throws an exception if the address is not a MAC address" {
            { New-IPv6LocalAddress -MacAddress $notMacAddress } |
            Should -Throw -ErrorId "NotMacAddress,New-IPv6LocalAddress"
        }
    }

    Context "Successes" {
        It "Should create an IPv6 Local Address" {
            $address = New-IPv6LocalAddress -MacAddress $macAddress

            GetIPAddressCompositionObjects $address | Should -Be $macAddress, 0, 0
        }

        It "Should create an IPv6 Local Address with Subnet ID" {
            $address = New-IPv6LocalAddress -MacAddress $macAddress -SubnetId $subnetId

            GetIPAddressCompositionObjects $address | Should -Be $macAddress, $subnetId, 0
        }

        It "Should create an IPv6 Local Address with Scope ID" {
            $address = New-IPv6LocalAddress -MacAddress $macAddress -ScopeId $scopeId

            GetIPAddressCompositionObjects $address | Should -Be $macAddress, 0, $scopeId
        }

        It "Should create an IPv6 Local Address with Subnet ID and Scope ID" {
            $address = New-IPv6LocalAddress -MacAddress $macAddress -SubnetId $subnetId -ScopeId $scopeId

            GetIPAddressCompositionObjects $address | Should -Be $macAddress, $subnetId, $scopeId
        }
    }
}
