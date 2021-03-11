Set-StrictMode -Version 3.0

$ModuleRoot = Split-Path -LiteralPath $PSScriptRoot -Resolve

Import-Module -Name $ModuleRoot -Force

Describe "ConvertTo-IPv6InterfaceId" {
    BeforeAll {
        $macAddress = [PhysicalAddress]::Parse("0022446688AA")
        $notMacAddress = [PhysicalAddress]::Parse("00224466")

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
            { ConvertTo-IPv6InterfaceId -MacAddress $notMacAddress } |
            Should -Throw -ErrorId "NotMacAddress,ConvertTo-IPv6InterfaceId"
        }
    }

    Context "Successes" {
        It "Should convert from MAC address to interface ID" {
            $iid = ConvertTo-IPv6InterfaceId -MacAddress $macAddress

            $iid.ToString() | Should -BeExactly "022244FFFE6688AA"
            (GetMacAddress $iid) | Should -Be $macAddress
        }
    }
}
