.eqv tags 0
.eqv PT-BR 1
.eqv EN-US 2
.eqv DE-DE 3
.eqv ELFNT 4


.data

qtd_de_linguas: .byte 5
lingua_atual:   .byte PT-BR

offset: 
tags:                                    .word        0,       44,      117,      184,      256, 
lang_name:                               .word        5,       50,      123,      190,      262, 
example:                                 .word       15,       71,      136,      203,      271, 
ex2:                                     .word       23,       88,      155,      223,      305, 
exit:                                    .word       27,       96,      163,      232,      356, 
teste:                                   .word       32,      101,      168,      240,      394, 
delim:                                   .word       38,      107,      174,      246,      400, 

strblock: .asciz "tags" "lang_name" "example" "ex2" "exit" "teste" "delim" "PT-BR" "Portugues Brasileiro" "Bom dia, senhor." "exemplo" "sair" "12345" "fim_PT-BR" "EN-US" "English (US)" "Good morning, sir." "example" "exit" "67890" "fim_EN-US" "DE-DE" "Deutsch (DE)" "Guten morgen, Herr." "Beispiel" "beenden" "ABCDE" "fim_DE-DE" "ELFNT" "Elefante" "Um elefante incomoda muita gente," "Dois elefantes\n- incomodam\n- incomodam\nmuito mais!" "Tres elefantes incomodam muita gente," "FGHIJ" "fim_ELFNT" "" 

# VERSAO DA BUILDTOOL CSV2ASM: 1.4.0 - 18 fevereiro 2026
