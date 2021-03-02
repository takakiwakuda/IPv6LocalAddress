---
external help file: IPv6LocalAddress-help.xml
Module Name: IPv6LocalAddress
online version: https://github.com/takakiwakuda/IPv6LocalAddress/blob/main/docs/ConvertTo-IPv6InterfaceId.md
schema: 2.0.0
---

# ConvertTo-IPv6InterfaceId

## SYNOPSIS
Converts a MAC address to an Interface ID.

## SYNTAX

```
ConvertTo-IPv6InterfaceId [-MacAddress] <PhysicalAddress> [<CommonParameters>]
```

## DESCRIPTION
The `ConvertTo-IPv6InterfaceId` cmdlet converts a MAC address to an Interface ID.

## EXAMPLES

### Example 1
```powershell
PS C:\> ConvertTo-IPv6InterfaceId -MacAddress "00-22-44-66-88-AA"
022244FFFE6688AA
```

This example converts the string representing the MAC Address to an Interface ID.

## PARAMETERS

### -MacAddress
Specifies the MAC Address to convert to an Interface ID.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Net.NetworkInformation.PhysicalAddress

You can pipe a MAC Address to `ConvertTo-IPv6InterfaceId`.

## OUTPUTS

### System.Net.NetworkInformation.PhysicalAddress

`ConvertTo-IPv6InterfaceId` returns a PhysicalAddress object representing an Interface ID.

## NOTES

## RELATED LINKS
