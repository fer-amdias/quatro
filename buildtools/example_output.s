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

strblock: .asciz "PT-BR" "Portugues Brasileiro" "Bom dia, senhor." "exemplo" "sair" "12345" "fim_PT-BR" "EN-US" "English (US)" "Good morning, sir." "example" "exit" "67890" "fim_EN-US" "DE-DE" "Deutsch (DE)" "Guten morgen, Herr." "Beispiel" "beenden" "ABCDE" "fim_DE-DE" "ELFNT" "Elefante" "Um elefante incomoda muita gente," "Dois elefantes\n- incomodam\n- incomodam\nmuito mais!" "Tres elefantes incomodam muita gente," "FGHIJ" "fim_ELFNT" "" 

# VERSAO DA BUILDTOOL CSV2ASM: 1.2.0 - 05 outubro 2025
