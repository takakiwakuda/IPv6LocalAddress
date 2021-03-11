---
external help file: IPv6LocalAddress-help.xml
Module Name: IPv6LocalAddress
online version: https://github.com/takakiwakuda/IPv6LocalAddress/blob/main/docs/New-IPv6LocalAddress.md
schema: 2.0.0
---

# New-IPv6LocalAddress

## SYNOPSIS

Generates an IPv6 Local Address.

## SYNTAX

```powershell
New-IPv6LocalAddress [-MacAddress] <PhysicalAddress> [-SubnetId <UInt16>] [-ScopeId <UInt32>]
 [<CommonParameters>]
```

## DESCRIPTION

This `New-IPv6LocalAddress` cmdlet generates an IPv6 Local Address.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-IPv6LocalAddress -MacAddress "00-22-44-66-88-AA"

AddressFamily      : InterNetworkV6
ScopeId            : 0
IsIPv6Multicast    : False
IsIPv6LinkLocal    : False
IsIPv6SiteLocal    : False
IsIPv6Teredo       : False
IsIPv4MappedToIPv6 : False
Address            :
IPAddressToString  : fd0f:1710:e9fd:0:222:44ff:fe66:88aa
```

This example generates the IPv6 Local Address from the specified MAC Address.

## PARAMETERS

### -MacAddress

Specifies the MAC Address.

```yaml
Type: PhysicalAddress
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ScopeId

Specifies the Scope ID.

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SubnetId

Specifies the Subned ID.

```yaml
Type: UInt16
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Net.NetworkInformation.PhysicalAddress

You can pipe a MAC Address to `New-IPv6LocalAddress`.

## OUTPUTS

### System.Net.IPAddress

`New-IPv6LocalAddress` returns an IPAddress object.

## NOTES

## RELATED LINKS

[ConvertTo-IPv6InterfaceId](https://github.com/takakiwakuda/IPv6LocalAddress/blob/main/docs/ConvertTo-IPv6InterfaceId.md)
