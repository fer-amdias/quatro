.eqv PT-BR 0
.eqv EN-US 1
.eqv DE-DE 2
.eqv ELFNT 3


.data

qtd_de_linguas: .byte 4
lingua_atual:   .byte PT-BR

offset: 
tags:                                    .word        0,       73,      140,      212, 
lang_name:                               .word        6,       79,      146,      218, 
example:                                 .word       27,       92,      159,      227, 
ex2:                                     .word       44,      111,      179,      261, 
exit:                                    .word       52,      119,      188,      312, 
teste:                                   .word       57,      124,      196,      350, 
delim:                                   .word       63,      130,      202,      356, 

strblock: .ascii "PT-BR\0Portugues Brasileiro\0Bom dia, senhor.\0exemplo\0sair\012345\0fim_PT-BR\0EN-US\0English (US)\0Good morning, sir.\0example\0exit\067890\0fim_EN-US\0DE-DE\0Deutsch (DE)\0Guten morgen, Herr.\0Beispiel\0beenden\0ABCDE\0fim_DE-DE\0ELFNT\0Elefante\0Um elefante incomoda muita gente,\0Dois elefantes\n- incomodam\n- incomodam\nmuito mais!\0Tres elefantes incomodam muita gente,\0FGHIJ\0fim_ELFNT\0" 

# VERSAO DA BUILDTOOL CSV2ASM: 1.0.1 - 26 setembro 2025
