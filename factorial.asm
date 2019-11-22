; multi-segment executable file template.

data segment
    n db 2 dup (0)  ;
    m db 14 dup (0) ;el metodo de ingresar numeros por vectores de numeros 
    f db 14 dup (0) ;
    a db 14 dup (0) ;
    mensaje1 db 'Ingrese un numero: $'
    mensaje2 db 'El factorial es: $'   
    mensaje3 db 'Dato invalido! $'
    pkey db 10,13,"press any key...$"
ends

stack segment
    dw   128  dup(0)
ends

code segment   
imprimir_car macro caracter
    mov dl,caracter
    add dl,30h               ;Macro lectura de caracter 
    mov ah,02h               
    int 21h
endm

imprimir_cad macro cadena
    lea dx,cadena  ;Macro despliegue de mensaje en pantalla 
    mov ah,09h
    int 21h
endm

limpiar_pantalla macro
    mov ah,00h
    mov al,03h          ;Macro limpieza de pantalla 
    int 10h
endm
start:
; set segment registers:
  mov ax,@data
    mov ds,ax
    
    imprimir_cad mensaje1 ;Impresion de pantalla mediante macro 
     preparar:
    xor di,di ;Preparacion del segmento di
    
ciclo_limpiar:
    mov f[di],00h   ;Inicializacion de la variables de memoria 
    mov m[di],00h 
    mov n[di],00h
    inc di        ;Incrementar el orden de incesrion del vector 
    cmp di,14           ;comparacion de di con un 14 en 
    jbe ciclo_limpiar ; si no hay esto de manda a ciclo de limpiar otra vez    
       
;Insertar numero
xor di,di   ;Limpieza del segemento di
 
ciclo_leer:
    mov ah,01h ;Lectura del caracter ascci de un numero 
    int 21h
    cmp al,0dh ;Comparacion con un 13 (Enter) en hexadecimal 
    je inicializacion ;Si se oprimio un enter se pasa a la siguiente fase                        
    sub al,30h ;resta de 30h para determinar el numeor decimal 
    
    mov n[di],al ;mover el contenido de al a la variable n con la ayuda de di
    inc di  ;incremento en di
    jmp ciclo_leer ;Se cicla en un bucle infinito si no detecta que se ha dado un enter 
    
inicializacion:  ;Programa en curso 
    cmp di,02h ;Verifica si en di de verdad hay un numero de dos digitos  
    ja error ;Salto a la seccion de error
    je dos_digitos ;Al ver el programa que son dos digitos el numero salta a la instruccion adecuada para su procesamiento 
    cmp di,00h  ;Comparacion de di con un 0 
    je error ;Si detecta que en di no hay datos validos salta a la parte de error
    
un_digito:
    cmp di,09h ;Comparacion de 0 a 9 para verificar si es un numero de un solo digito 
    ja error  ; si excede da error
    jmp factorial ;salta al proceso matematico
    
dos_digitos:
    cmp n[0],01h  ;Verifica si en el indice n[0] hay un 1
    ja error      ;Si no lo hay manda a error
    xor ax,ax  ;Limpieza segmento ax
    xor bx,bx  ;Limpieza segmento bx 
    mov al,n[0]  ;mover a al lo que tenga el indice 0 del numero 
    mov bl,0ah   ;mover a bh un 10
    mul bl    ;multiplicar bl por al
    add n[1],al ;suma lo que tenga el al al indice 1
    mov al,n[1] ;mover al lo que tenga el inidice 1
    mov n[0],al ;guardar lo que tenga el registro al en el indice 0 
    jmp factorial  ;Salta al proceso de factorial

factorial:
    mov cl,01h ;mover a cl un 01 
    mov m[0],01h ;mover al indice m[0] un 1
    xor bx,bx ;Limpieza de todos los registros necesarios para el proceso de factorial
    xor ax,ax
    xor si,si
    xor di,di
    
ciclo1:
    mov al,cl ;mover a al lo que tenga cl
    mul m[si] ; multiplicar a m con la indice del valor de si      
    
    aam  ;multiplicacion con ajuste en ax
    
    mov a[si],al ;mover al hacia el indice de la variable 'a' de acorde a si  
    
    mov a[si+1],ah  ;mover a 'a' con un incremento en el indice de de acorde a si  lo que tenga ah
    
    xor ax,ax ;limpiar  ax
    
    mov al,a[si] ;mover a al lo que tenga 'a' en el indice si 
    add al,f[si]  ;sumar lo que tenga la variable f indexada a al 
    aaa  ; ajuste de la suma en ax
    mov f[si],al ;mover a f con direccionamiento indexado de si lo que tiene a al 
    
    add a[si+01h],ah ;sumar a [a] si con incremento en uno lo que tenga con el fin de llenar el vector con sumas  
    
    mov al,a[si+01h] ;mover a al lo que tenga el vector a [Indexado si con un incremento en 1]
    add f[si+01h],al ;sumar lo que se encuentre en al con f[incrementando en 1 si]
    
    inc si ;incrementar si 
    inc bl ;incrementar bl
         
    cmp bl,0dh ; comprarar bl con un 13
    jbe ciclo1 ;si no se cumple la condicion salta a ciclo 1 
    
    mov si,00h ;mover a si un 0
    mov bl,00h  ;mover a bl un 0
    
ciclo2:
    mov al,f[si] ;mover a al lo que tenga F[con indexado de si]
    mov m[si],al ; mover lo que tenga al al vector m[con indexacion]
    mov al,00h ;mover a al un 0
    mov f[si],al ;mover lo que tenga al a al vector f[Con indice en si]
    
    inc si ;incrementar si
    inc bl  ;incrementar bl
    
    cmp bl,0dh ;comparar de bl con un 13 
    jbe ciclo2 ;sino se cumple esta condicion salta a ciclo 2 
    
    mov si,00h  ;mover a si un 0
    mov bl,00h  ;mover a bl un 0
    
    inc cl ;incrementar cl
    
    cmp cl,n[di] ;comparar cl a con n[di]  
    jbe ciclo1 ;si se cumple la condicion salta a ciclo1 
    jmp resultado ; sino se cumple salta a ciclo salir 

resultado:
    limpiar_pantalla   ;llamada de macros 
    imprimir_cad mensaje2 ; llama de macros para mandar ,mensaje a pantalla
    mov si,0eh
    
ciclo_resultado:
    dec si      ;reducir el contador si
    imprimir_car m[si]    ;imprimir m con indice si
    cmp si,00h            ;comprobar si en si hay un 0
    jne ciclo_resultado   ;si no hay un 0 repetir el bucle
    jmp salir            ;si hay un 0 salta a salir 
    
error:
   limpiar_pantalla     ;limpia la pantalla
   imprimir_cad mensaje3     ;muestra mensaje de error 
   
salir:       
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
