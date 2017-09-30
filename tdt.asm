; FUNCIONES de C
  extern malloc
  extern free
  extern strcpy
  extern tdt_agregar
  extern tdt_borrar
  
  ;EXTERN tdt_traducir

; FUNCIONES
  global tdt_crear
  global tdt_recrear
  global tdt_cantidad
  global tdt_agregarBloque
  global tdt_agregarBloques
  global tdt_borrarBloque
  global tdt_borrarBloques
  global tdt_traducir
  global tdt_traducirBloque
  global tdt_traducirBloques
  global tdt_destruir

; /** defines offsets y size **/
  %define TDT_OFFSET_IDENTIFICACION   0
  %define TDT_OFFSET_PRIMERA          8
  %define TDT_OFFSET_CANTIDAD        16
  %define TDT_SIZE                   20

  %define TDT3_VALOR                  0
  %define TDT3_VALIDO                 15
  
  %define NULL                        0
  
  %define TDTN_OFFSET_ENTRADAS        0

  %define ENTRADAS_OFFSET_SIG         8
  
  %define VALOR_OFFSET_VAL            0

  %define CLAVE_OFFSET_CLA            0

  %define CLA_OFFSET_PRI              0
  %define CLA_OFFSET_SEG              1
  %define CLA_OFFSET_TER              2

  %define BLOQUEOFF_CLAVE             0
  %define BLOQUEOFF_VALOR             3


section .text

; =====================================
; tdt* tdt_crear(char* identificacion)
tdt_crear:
  ;en rdi tengo un puntero al string de la identificacion
  ;pusheo registros a la pila
  push rbp
  mov rbp, rsp
  push rbx      ;el puntero a la identificacion
  push r12      ;dejo alineada la pila

  ;paso el puntero de rdi a rbx para que no se pierda
  mov rbx, rdi

  ;pido memoria para crear un tdt
  mov qword rdi, TDT_SIZE
  call malloc

  ;la memoria pedida esta en rax que es donde devuelvo

  ;agrego la identificacion que tengo en rbx
  mov qword [rax + TDT_OFFSET_IDENTIFICACION], rbx
  ;hago que el puntero a la primer tabla tdtn1 sea null
  mov qword [rax + TDT_OFFSET_PRIMERA], NULL
  ;hago el la cantidad de tdt sea 0
  mov dword [rax + TDT_OFFSET_CANTIDAD], 0

  pop r12
  pop rbx
  pop rbp
  ret



; =====================================
; void tdt_recrear(tdt** tabla, char* identificacion)
tdt_recrear:
  ;en rdi recibo un puntero de puntero a tabla
  ;en rsi recibo un puntero a la nueva identificacion (string)

  ;armo el stack frame
  push rbp
  mov rbp, rsp
  push rbx        ;guardo el puntero a puntero a tabla
  push r12        ;guardo el puntero a char
  push r13        ;guardo el puntero a la tabla nueva
  push r14        ;para alinear la pila

  ;guardo el puntero a puntero a tabla en rbx
  mov rbx, rdi

  ;guardo el puntero a la identificacion en r12
  mov r12, rsi

  ;vacio la tabla que me pasan como parametro
  mov rdi, [rbx]
  call vaciar_tabla

  ;en rdi tengo la tabla vacia
  ;reviso si la identificacion que me pasaron es null, si lo es dejo
  ;la que esta
  cmp r12, NULL
  je .continuar

  ;camibio la identificacion
  mov [rdi + TDT_OFFSET_IDENTIFICACION], r12

  .continuar:
  ;paso el puntero rdi a [rbx]
  mov [rbx], rdi

  ;paso rbx a rdi y r12 a rsi
  mov rdi, rbx
  mov rsi, r12

  .fin:
  ;popeo la pila
  pop r14
  pop r13
  pop r12
  pop rbx
  pop rbp
  ret



; =====================================
; uint32_t tdt_cantidad(tdt* tabla)
tdt_cantidad:
  ;en rdi tengo un puntero a la tabla tdt
  ;pusheo el rbp
  push rbp
  mov rbp, rsp

  ;lo voy a usar para pasar el valor de 4B de la tabla
  mov  rax, 0
  ;paso el valor a esi (parte baja de 32bits de rsi)
  mov eax, [rdi + TDT_OFFSET_CANTIDAD]

  pop rbp
  ret



; =====================================
; void tdt_agregarBloque(tdt* tabla, bloque* b)
tdt_agregarBloque:
  ;en rdi recibo el puntero a tabla
  ;en rsi recibo el puntero al bloque

  ;armo el stack frame
  push rbp
  mov rbp, rsp

  ;en rsi tengo el puntero a la clave
  ;en rdx pongo el puntero al valor
  lea rdx, [rsi + BLOQUEOFF_VALOR]

  ;llamo a agregar que agrega los valores
  ;rdi = tdt* // rsi = *clave // rdx = *valor
  call tdt_agregar

  pop rbp
  ret



; =====================================
; void tdt_agregarBloques(tdt* tabla, bloque** b)
tdt_agregarBloques:
  ;en rdi recibo el puntero a tabla
  ;en rsi recibo el puntero a punteros de bloque

  ;armo el stack frame
  push rbp
  mov rbp, rsp
  push rbx      ;puntero a la tabla
  push r12      ;puntero a puntero a bloque

  ;paso el puntero de la tabla a rbx
  mov rbx, rdi
  ;paso el puntero a puntero a bloque a r12
  mov r12, rsi

  ;mientras no sea puntero a null los bloques va a ciclar
  .ciclo:
  ;muevo a rdi el puntero a tabla de rbx (tdt_agregarBloque llama a tdt_agregar que llama a malloc)
  mov rdi, rbx
  ;muevo el puntero al proximo bloque a rsi
  mov rsi, [r12]
  cmp rsi, NULL
  je .fin
  ;si es distinto de null llamo a tdt_agregarBloque
  call tdt_agregarBloque
  ;me muevo al siguiente puntero
  add r12, 8
  jmp .ciclo

  .fin:
  pop r12
  pop rbx
  pop rbp
  ret



; =====================================
; void tdt_borrarBloque(tdt* tabla, bloque* b)
tdt_borrarBloque:
  ;en rdi tengo un puntero a la tabla
  ;en rsi tengo un puntero al bloque

  ;como tengo un puntero al bloque y el primer elemento es la clave
  ;entonces es como tener un puntero a la clave y puedo llamar a
  ;tdt_borrar

  ;armo el stack frame

  jmp tdt_borrar



; =====================================
; void tdt_borrarBloques(tdt* tabla, bloque** b)
tdt_borrarBloques:
  ;en rdi tengo el puntero a la tabla
  ;en rsi tengo el puntero a puntero bloque

  ;armo el stackframe
  push rbp
  mov rbp, rsp
  push rbx      ;puntero a tabla
  push r12      ;puntero a puntero a bloque

  ;muevo a rbx el puntero a la tabla
  mov rbx, rdi

  ;muevo a r12 el puntero a puntero a bloque
  mov r12, rsi

  .ciclo:
  ;paso el puntero del bloque que apunta r12 a rsi
  mov rsi, [r12]
  ;si es null sale termina el programa
  cmp rsi, NULL
  je .fin
  ;si no es null muevo el puntero a la tabla a rdi y llamo a
  ;tdt_borrarBloque
  mov rdi, rbx
  call tdt_borrarBloque
  ;actualizo el puntero
  add r12, 8
  jmp .ciclo

  .fin:
  pop r12
  pop rbx
  pop rbp
  ret        


; =====================================
; void tdt_traducir(tdt* tabla, uint8_t* clave, uint8_t* valor)
tdt_traducir:
;recibo el puntero a la tabla en rdi
;recibo el puntero a la clave en rsi
;recibo el puntero al valor en rdx

  push rbp
  mov rbp, rsp
  push rbx      ;puntero a primera
  push r12      ;puntero a segunda
  push r13      ;puntero a tercera
  push r14

  ;reviso si el puntero de la tabla o de la clave son null, si lo son
  ;termina el programa
  cmp rdi, NULL
  je .fin
  cmp rsi, NULL
  je .fin

  ;los punteros no son null
  ;paso el puntero a la primer tabla a rbx
  mov rbx, [rdi + TDT_OFFSET_PRIMERA]

  ;si el puntero a primera es null termina
  cmp rbx, NULL
  je .fin

  ;no es null el puntero a la primer tabla
  ;paso el primer valor de la clave a rax
  mov rax, 0
  mov al, [rsi + CLA_OFFSET_PRI]

  ;busco el puntero a la segunda tabla
  mov r12, [rbx + rax*8]

  ;si el puntero a la segunda tabla es null termina
  cmp r12, NULL
  je .fin

  ;aqui no es null, el puntero a la segunda tabla
  ;paso el segundo valor de la clave a rax
  mov rax, 0
  mov al, [rsi + CLA_OFFSET_SEG]

  ;busco el puntero a la tercer tabla
  mov r13, [r12 + rax*8]

  ;si el puntero a la tercer tabla es null termina
  cmp r13, NULL
  je .fin

  ;el puntero a la tercer tabla no es null, busco a que apunte al elem
  ;que necesito
  ;paso a rax el valor del tercer elemento de la clave
  mov rax, 0
  mov al, [rsi + CLA_OFFSET_TER]

  ;multiplico el valor de al por 16 (con un shift) porque no puedo
  ;multiplicar a rax por 16
  sal rax, 4

  ;aca simplemente paso el puntero al struct valorValido que necesito
  lea r14, [r13 + rax]

  ;reviso si el valor es valido, uso al (rax)
  mov rax, 0
  mov al, [r14 + TDT3_VALIDO]
  ;si el valor no es valido termina
  cmp al, 0
  je .fin

  ;el valor es valido
  ;paso el valor
  ;hago cero rcx y lo uso para loopear
  mov rcx, 0
  mov rax, 0

  .pasoValor:
  cmp rcx, 15
  je .fin
  mov al, [r14 + rcx]
  mov [rdx], al
  add rdx, 1    ;es de a un Byte
  inc rcx
  jmp .pasoValor

  .fin:
  pop r14
  pop r13
  pop r12
  pop rbx
  pop rbp
  ret



; =====================================
; void tdt_traducirBloque(tdt* tabla, bloque* b)
tdt_traducirBloque:
  ;recibo en rdi un puntero a la tabla
  ;recibo en rsi un puntero al bloque

  ;en rdi ya tengo el puntero a la tabla
  ;en rsi tengo el puntero al bloque y a los primeros valores de clave
  ;en rdx agrego el puntero del valor del bloque y listo, llamo a tdt_traducir

  ;armo el stack frame
  push rbp
  mov rbp, rsp

  lea rdx, [rsi + BLOQUEOFF_VALOR]

  ;tengo los valores que necesito
  ;llamo a tdt_traducir
  call tdt_traducir

  ;fin
  pop rbp
  ret



; =====================================
; void tdt_traducirBloques(tdt* tabla, bloque** b)
tdt_traducirBloques:
  ;recibo en rdi el puntero a la tabla
  ;recibo en rsi el puntero al vector de bloques

  ;armo el stack frame
  push rbp
  mov rbp, rsp
  push rbx        ;puntero a la tabla
  push r12        ;puntero a puntero a bloque

  ;muevo el puntero de rdi a rbx
  mov rbx, rdi

  ;muevo el puntero de rsi a r12
  mov r12, rsi

  .ciclo:
  ;muevo el puntero al bloque a rsi
  mov rsi, [r12]
  ;reviso si rsi es null, si lo es termino
  cmp rsi, NULL
  je .fin
  ;muevo el puntero a la tabla de rbx a rdi
  mov rdi, rbx
  ;llamo a tdt_traducir
  call tdt_traducirBloque
  ;actualizo el puntero a puntero a bloque
  add r12, 8
  jmp .ciclo

  .fin:
  pop r12
  pop rbx
  pop rbp
  ret



; =====================================
; void tdt_destruir(tdt** tabla)
tdt_destruir:
  ;en rdi recibo un puntero a puntero a tabla
  ;armo el stack frame
  push rbp
  mov rbp, rsp
  push rbx      ;puntero a puntero a la tabla  (** tabla)
  push r12      ;puntero a la tabla            (* tabla)
  ;aca esta alineada a 16

  ;paso el puntero a puntero a tabla a rbx
  mov rbx, rdi
  ;si el puntero es null termino
  cmp rbx, NULL
  je .fin

  ;paso el puntero a tabla a r12
  mov r12, [rbx]

  ;muevo a rdi el puntero a la tabla
  mov rdi, r12
  call vaciar_tabla

  .borrarUltimoPuntero:
  ;paso a rdi el puntero a de tabla que esta en r12
  mov rdi, r12
  call free

  ;devuelvo el puntero a puntero a tabla a rdi
  mov rdi, rbx

  .fin:
  pop r12
  pop rbx
  pop rbp
  ret



 ; =====================================
; void vaciar_tabla(tdt* tabla)
vaciar_tabla:
  ;en rdi recibo un puntero a tabla
  ;armo el stack frame

  push rbp
  mov rbp, rsp
  sub rsp, 24   ;tengo 3 variables para poder ir ciclando entre 
                ;las tablas
                ;[rbp - 8] --> i
                ;[rbp - 16] --> j
                ;[rbp - 24] --> para alinear

  push rbx      ;FRUTA
  push r12      ;puntero a la tabla            (* tabla)
  push r13      ;puntero a la primer tabla     (* primera) 
  push r14      ;puntero a la segunda tabla    (* segunda)
  push r15      ;puntero a la tercer tabla     (* tercera)
  ;aca esta alineada a 16

  ;paso el puntero a tabla a r12
  mov r12, rdi
  ;si el putnero es null termino
  cmp r12, NULL
  je .fin

  ;pongo la primer tabla en r13
  mov r13, [r12 + TDT_OFFSET_PRIMERA]

  ;si la primer tabla es null borro el puntero a puntero a tabla y fin
  cmp r13, NULL
  je .fin

  ;hay primera, empiezo el ciclo
  ;limpio el i ([rbp - 8]) para poder ciclar
  mov qword [rbp - 8], 0


  .cicloPrimerTabla:
  cmp qword [rbp - 8], 256
  je .borroPrimerTabla
  ;no es el ultimo elem
  ;paso el puntero a la segunda tabla que esta en r14
  mov r14, [r13]
  ;comparo si es null, si no lo es tengo que ciclar en la seg tabla
  cmp r14, NULL
  jne .revisoSegundaTabla
  .continuoCicloPrimerTabla:
  ;actualizo el puntero de r13 y sumo en uno [rbp - 8]
  inc qword [rbp - 8]
  add r13, 8    ;es de punteros, valor 8Bytes
  jmp .cicloPrimerTabla


  .revisoSegundaTabla:
  ;limpio el j ([rbp - 16]) para poder ciclar
  mov qword [rbp - 16], 0
  
  .cicloSegundaTabla:
  cmp qword [rbp - 16], 256
  je .borroSegundaTabla
  ;no es el ultimo elem
  ;paso el puntero a la tercer tabla que esta en r15
  mov r15, [r14]
  ;comparo si es null, si no lo es tengo que liberar la memoria
  cmp r15, NULL
  jne .borroTercerTabla
  .continuoCicloSegundaTabla:
  ;actualizo el puntero de r14 y sumo en uno [rbp - 16]
  inc qword [rbp - 16]
  add r14, 8    ;es de punteros, valor 8B
  jmp .cicloSegundaTabla


  .borroTercerTabla:
  ;paso el puntero de la tercer tabla a rdi
  mov rdi, [r14]
  ;hago el puntero de la segunda tabla null
  mov qword [r14], NULL
  ;libero la memoria
  call free
  ;vuelvo al ciclo de la segunda tabla
  jmp .continuoCicloSegundaTabla


  .borroSegundaTabla:
  ;paso el puntero a la segunda tabla a rdi
  mov rdi, [r13]
  ;hago null el puntero a la segunda en la tabla
  mov qword [r13], NULL
  ;llamo a free
  call free
  jmp .continuoCicloPrimerTabla


  .borroPrimerTabla:
  ;paso el puntero a la primer tabla a rdi
  mov rdi, [r12 + TDT_OFFSET_PRIMERA]
  ;hago NULL el puntero de la tabla
  mov qword [r12 + TDT_OFFSET_PRIMERA], NULL
  ;libero la memoria
  call free

  ;devuelvo el puntero a puntero a tabla a rdi
  mov rdi, r12

  .fin:
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbx
  add rsp, 24
  pop rbp
  ret