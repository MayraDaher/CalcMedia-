.686
.model flat, stdcall                    ;Modelo de mem�ria FLAT / stdcall - passagem de par�metros utilizada pelo windows
option casemap: none                    ;Case sensitive
.xmm                                    ;Para utiliza��o dos registradores vetoriais 

include \masm32\include\windows.inc     
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib


.data
nomeAluno db 600 dup(0)                 ;string para armazenar o nome do(a) aluno(a)
notas1 db 20 dup(0)                     ;array para armazenar as primeiras notas recebidas
notas2 db 20 dup(0)                     ;array para armazenar as segundas notas recebidas
notas3 db 20 dup(0)                     ;array para armazenar as terceiras notas recebidas
notas1R8 dq 40 dup(0)                   ;array para armazenar as notas 1 depois de convertidas para QWORD
notas2R8 dq 40 dup(0)                   ;array para armazenar as notas 2 depois de convertidas para QWORD
notas3R8 dq 40 dup(0)                   ;array para armazenar as notas 3 depois de convertidas para QWORD
notas1R4 dd 40 dup(0)                   ;array para armazenar as notas 1 depois de convertidas para DWORD
notas2R4 dd 40 dup(0)                   ;array para armazenar as notas 2 depois de convertidas para DWORD
notas3R4 dd 40 dup(0)                   ;array para armazenar as notas 3 depois de convertidas para DWORD
const3 dd 4 dup(3.0)                    ;array inicializado com valor 3 em suas posi��es, ser� utilizado no c�lculo das m�dias
mediasR4 dd 40 dup(0.0)                 ;array para armazenar as m�dias depois de convertidas para REAL4    
mediasR8 dq 40 dup(0.0)                 ;array para armazenar as m�dias depois de convertidas para REAL8
medias db 20 dup(0)                     ;array para armazenar as m�dias convertidas em string 

;Textos dos Menus
menu db "Digite a opcao desejada: ", 0ah, "1 para incluir notas dos(as) alunos(as)", 0ah, "2 para exibir medias da turma", 0ah, "3 para sair do programa.", 0ah, 0h
menuNome db "Insira o nome do(a) aluno(a): ", 0ah, 0h                               
menuNotas1 db "Insira a primeira nota do(a) aluno(a): ", 0ah, 0h                    
menuNotas2 db "Insira a segunda nota do(a) aluno(a): ", 0ah, 0h
menuNotas3 db"Insira a terceira nota do(a) aluno(a): ", 0ah, 0h
pergunta db "Deseja continuar inserindo alunos e notas? Digite 1 para sim, e 2 para nao.", 0ah, 0h
msgLimite db "Limite de alunos atingido!", 0ah, 0h

;Textos para impress�es das notas
novaLinha db 0ah, 0h
msgNome db "Aluno(a): ", 0h
msgNota1 db "Nota 1: ", 0h
msgNota2 db "Nota 2: ", 0h
msgNota3 db "Nota 3: ", 0h
msgMedia db "Media: ", 0h


outputHandle dd 0                       ;Vari�vel que armazena o handle para o buffer do console
writeCount dd 0                         ;Vari�vel de retorno que cont�m o n�mero de bytes escritos 

inputHandle dd 0                        ;armazena o handle pro buffer do console
consoleCount dd 0                       ;vari�vel de retorno que cont�m o n�mero de bytes recebidos
tamanhoString dd 0                      ;armazena o tamanho da string
contadorNomes dd 0                      ;contador da quantidade de nomes cadastrados
contadorAlunos dd 0                     ;contador da quantidade de alunos cadastrados
contImp dd 0                            ;contador utilizado no loop para impress�o das notas
contLoop dd 0                           ;Contador de loops utilizado no c�lculo das m�dias


.code
start:
preludio:
;Capturando os handles de entrada e sa�da do console
invoke GetStdHandle, STD_INPUT_HANDLE   
mov inputHandle, eax
invoke GetStdHandle, STD_OUTPUT_HANDLE
mov outputHandle, eax
;Impress�o na tela do menu inicial
invoke WriteConsole, outputHandle, addr menu, sizeof menu, addr writeCount, NULL

;Recebendo a entrada do usu�rio
invoke ReadConsole, inputHandle, addr inputString, sizeof inputString, addr consoleCount, NULL

;Para retirar o Carriage Return da string convertida atrav�s do ReadConsole:
mov esi, offset inputString         ;armazena o apontador da string em esi
next:
    mov al, [esi]                   ;aramzena o caracter em al
    inc esi                         ;incrementa esi e aponta para o pr�ximo
    cmp al, 48                      ;compara o valor armazenado em al com ASCII 48
    jl terminar                     ;jump se menor e volte para terminar
    cmp al, 58                      ;compara o valor armazenado em al com ASCII 58
    jl next                         ;jump se menor e voltar para next 
terminar:
    dec esi                         ;decrementa esi e aponta para o caracter anterior
    xor al, al                      ;zerar o valor de al
    mov [esi], al                   ;inserir NULL ap�s o t�rmino do n�mero
invoke atodw, addr inputString      ;convers�o para tipo num�rico
cmp eax, 1                          ;compara a entrada do usu�rio com 1
je menu1                            ;Se igual, jump para a label menu1
cmp eax, 2                          ;compara a entrada do udu�rio com 2
je menu2                            ;se igual, jump para a label menu2
cmp eax, 3                          ;compara a entrada do usu�rio com 3
je encerrar                         ;Se igual, jump para a label encerrar
ja preludio                         ;Caso a entrada do udu�rio seja maior que os valores anteriores, jump para a label prel�dio    

menu1:

inicio:
    ;Menu que pede o nome do aluno a ser cadastrado
    invoke WriteConsole, outputHandle, addr menuNome, sizeof menuNome, addr writeCount, NULL
    ;Percorre o array para armazenar os nomes
    mov eax, contadorNomes
    mov ebx, 15
    mul ebx
    add eax, offset nomeAluno
    invoke ReadConsole, inputHandle, eax, 15, addr consoleCount, NULL

    ;Menu que pede a primeira nota a ser cadastrada
    invoke WriteConsole, outputHandle, addr menuNotas1, sizeof menuNotas1, addr writeCount, NULL
   
    invoke ReadConsole, inputHandle, addr notas1, sizeof notas1, addr consoleCount, NULL
    ;Percorrendo o array notas1R8
    mov eax, contadorAlunos
    mov ebx, 8
    mul ebx
    mov ebx, eax
    push ebx
    ;convertendo a nota de string pra QWORD e armazenando no array notas1R8
    invoke StrToFloat, offset notas1, addr [notas1R8+eax]
    ;Percorrendo e preenchendo o array notas1R4 
    mov eax, contadorAlunos
    mov ebx, 4
    mul ebx
    pop ebx
    fld REAL8 PTR[notas1R8+ebx]
    fstp REAL4 PTR[notas1R4+eax]
    
    ;Menu que pede a segunda nota a ser cadastrada
    invoke WriteConsole, outputHandle, addr menuNotas2, sizeof menuNotas2, addr writeCount, NULL
    
    invoke ReadConsole, inputHandle, addr notas2, sizeof notas2, addr consoleCount, NULL
    ;Percorrendo o array notas2R8
    mov eax, contadorAlunos
    mov ebx, 8
    mul ebx
    mov ebx, eax
    push ebx
    ;convertendo a nota de string para QWORD e aramzenando no array notas2R8
    invoke StrToFloat, offset notas2, addr [notas2R8+eax]
    ;percorrendo e preenchendo o array notas2R4
    mov eax, contadorAlunos
    mov ebx, 4
    mul ebx
    pop ebx
    fld REAL8 PTR[notas2R8+ebx]
    fstp REAL4 PTR[notas2R4+eax]

    ;Menu que pede a terceira nota a ser cadastrada
    invoke WriteConsole, outputHandle, addr menuNotas3, sizeof menuNotas3, addr writeCount, NULL

    invoke ReadConsole, inputHandle, addr notas3, sizeof notas3, addr consoleCount, NULL
    ;Percorrendo o array notas2R8
    mov eax, contadorAlunos
    mov ebx, 8
    mul ebx
    mov ebx, eax
    push ebx
    invoke StrToFloat, offset notas3, addr [notas3R8+eax]
    ;percorrendo e preenchendo o array notas3R4
    mov eax, contadorAlunos
    mov ebx, 4
    mul ebx
    pop ebx
    fld REAL8 PTR[notas3R8+ebx]
    fstp REAL4 PTR[notas3R4+eax]
    
    inc contadorNomes                   ;Incrementa o contadorNomes ao final do cadastro de um novo aluno
    inc contadorAlunos                  ;Incrementa o contadorAlunos ao final do cadastro de um novo aluno
    cmp contadorAlunos, 40              ;Compara a quantidade de alunos j� cadastrados com o limite pr�-estabelecido
    jae finalizar                       ;Se acima ou igual a 40, finalizar cadastro de novos alunos
    jmp preludio                        ;Se n�o, retorna para o menu inicial
     
finalizar:
    ;Caso o limite seja atingido, imprime a mensagem de limite
    invoke WriteConsole, outputHandle, addr msgLimite, sizeof msgLimite, addr writeCount, NULL
    
menu2:
    ;Calculando quantos loops precisam ser feitos
    xor edx, edx                        
    mov eax, contadorAlunos
    mov ebx, 4
    div ebx                             ;Dividindo a quantidade de alunos por 4 
    cmp edx, 0                          ;O resto da divis�o fica em edx. Precisamos comparar com 0 para saber se precisa de mais loops
    jne mais_um                         ;Se o resto n�o for igual a 0, ent�o mais um.
    mov contLoop, eax
    jmp continuar
    mais_um:
    mov contLoop, eax
    inc contLoop                        ;atualiza o valor do contador de loops

    continuar:
    ;Percorrendo e preenchendo os registardores vetoriais com as notas dos alunos       
    mov eax, contImp                    ;usa o conte�do do contador para percorrer o vetor
    mov ebx, 16                         
    mul ebx                     
    push eax                            ;preserva o valor de eax                   
    add eax, offset notas1R4        
    movups xmm0, OWORD PTR [eax]        ;armazena em xmm0 o conte�do do array notas1R4
    pop eax                         
    push eax                            ;preserva o valor de eax (contador)
    add eax, offset notas2R4
    movups xmm1, OWORD PTR [eax]        ;preenche xmm1 com valores do array notas2R4
    pop eax
    push eax                            ;preserva valor de eax (contador)
    add eax, offset notas3R4
    movups xmm2, OWORD PTR [eax]        ;preenche xmm2 com valores do array notas3R4
    movups xmm3, OWORD PTR [const3]     ;preenche xmm3 com valores do array const3
    addps xmm0, xmm1                    ;adiciona em xmm0 os valores de xmm1 
    addps xmm0, xmm2                    ;adiciona em xmm0 os valores de xmm2
    divps xmm0, xmm3                    ;divide o somat�rio das notas por 3.0 (conte�do de xmm3)
    pop eax
    add eax, offset mediasR4
    movups OWORD PTR [eax], xmm0    
    inc contImp                         ;incrementa o contador que vai controlar a quantidade de notas/m�dias de alunos a serem impressas
    mov eax, contImp        
    cmp contLoop, eax                   ;atualiza o valor do contador de loops               
    jne continuar

    mov contImp, 0

    ;convertendo de float para string e imprimindo no console
    converter:
    mov eax, contImp
    mov ebx, 15
    mul ebx                             ;calculando a posi��o no vetor
    push eax
    invoke StrLen, addr nomeAluno
    mov tamanhoString, eax
    invoke WriteConsole, outputHandle, addr msgNome, sizeof msgNome, addr writeCount, NULL
    pop eax
    ;Imprimindo o nome do aluno na respectiva posi��o 
    invoke WriteConsole, outputHandle, addr [nomeAluno+eax], tamanhoString, addr writeCount, NULL
    ;Pulando uma linha na impress�o
    invoke WriteConsole, outputHandle, addr novaLinha, sizeof novaLinha, addr writeCount, NULL    
    mov eax, contImp
    mov ebx, 8
    mul ebx
    push eax
    ;Convertendo as notas1 de float para string
    invoke FloatToStr, [notas1R8 + eax], offset notas1
    invoke StrLen, addr notas1
    mov tamanhoString, eax
    invoke WriteConsole, outputHandle, addr msgNota1, sizeof msgNota1, addr writeCount, NULL
    ;Imprimindo na tela a primeira nota do respectivo aluno
    invoke WriteConsole, outputHandle, addr notas1, tamanhoString, addr writeCount, NULL
    ;Pulando uma linha para impress�o
    invoke WriteConsole, outputHandle, addr novaLinha, sizeof novaLinha, addr writeCount, NULL

    pop eax
    push eax
    ;Convertendo as notas1 de float para string
    invoke FloatToStr, [notas2R8 + eax], offset notas2
    invoke StrLen, addr notas2
    mov tamanhoString, eax
    invoke WriteConsole, outputHandle, addr msgNota2, sizeof msgNota2, addr writeCount, NULL
    ;Imprimindo na tela a segunda nota do respectivo aluno
    invoke WriteConsole, outputHandle, addr notas2, tamanhoString, addr writeCount, NULL
    ;Pulando uma linha para impress�o
    invoke WriteConsole, outputHandle, addr novaLinha, sizeof novaLinha, addr writeCount, NULL
    pop eax
    ;Convertendo de float para string
    invoke FloatToStr, [notas3R8 + eax], offset notas3
    invoke StrLen, addr notas3
    mov tamanhoString, eax
    invoke WriteConsole, outputHandle, addr msgNota3, sizeof msgNota3, addr writeCount, NULL
    ;Imprimindo na tela a primeira nota do respectivo aluno
    invoke WriteConsole, outputHandle, addr notas3, tamanhoString, addr writeCount, NULL
    ;Pulando uma linha para impress�o
    invoke WriteConsole, outputHandle, addr novaLinha, sizeof novaLinha, addr writeCount, NULL

    ;Convertendo de REAL4 para REAL8 e, em seguida, para string (para impress�o na console) 
    ;Percorrendo o array mediasR4
    mov eax, contImp
    mov ebx, 8
    mul ebx
    mov ebx, eax
    push ebx                            ;preservando o valor de ebx 
    ;percorrendo o array mediasR8   
    mov eax, contImp
    mov ebx, 4
    mul ebx
    pop ebx
    push ebx
    fld REAL4 PTR [mediasR4 + eax]      ;Carrega numero de precisao simples na pilha
    fstp REAL8 PTR [mediasR8 + ebx]     ;carrega n�mero de precis�o dupla na vari�vel
    pop ebx
    ;Converte de precis�o dupla pra string
    invoke FloatToStr, [mediasR8 + ebx], offset medias
    invoke StrLen, addr medias
    mov tamanhoString, eax
    
    invoke WriteConsole, outputHandle, addr msgMedia, sizeof msgMedia, addr writeCount, NULL
    ;imprime as m�dias na consoloe
    invoke WriteConsole, outputHandle, addr medias, tamanhoString, addr writeCount, NULL
    ;pula 2 linhas da impress�o
    invoke WriteConsole, outputHandle, addr novaLinha, sizeof novaLinha, addr writeCount, NULL
    invoke WriteConsole, outputHandle, addr novaLinha, sizeof novaLinha, addr writeCount, NULL

    ;Verifica se todos os alunos e notas armazenados j� foram impressos
    add contImp, 1
    mov ebx, contImp
    cmp ebx, contadorAlunos             
    jb converter

jmp preludio   

encerrar:
    invoke ExitProcess, 0
end start
