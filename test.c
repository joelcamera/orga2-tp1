#include "tdt.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

void imprimir(uint8_t* v, int cant);

int main (void){

    tdt* tabla = tdt_crear("sa");

    tdt_destruir(&(tabla));


    /************ EJERCICIO 2 *************/
    //1)
    tdt* t = tdt_crear("pepe");


    //2)
    uint8_t c1[3] = {0,0,0};
    uint8_t v1[15] = {255,255,255,255,255,255,255,255,255,255,255,255,255,255,255};

    uint8_t c2[3] = {255,255,255};
    uint8_t v2[15] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

    tdt_agregar(t,c1,v1);
    tdt_agregar(t,c2,v2);


    //3)
    //creo los bloques
    bloque b1 = {{5,5,5},{18,52,86,120,154,188,222,241,35,69,103,137,171,205,239}};
    bloque b2 = {{255,255,255}, {17,34,51,68,85,102,119,136,153,170,187,204,221,238,255}};
    bloque b3 = {{83,255,170}, {17,18,34,51,52,68,85,86,102,119,120,136,153,154,170}};
    bloque b4 = {{16,238,5}, {17,17,34,34,51,51,68,68,85,85,102,102,119,119,136}};

    bloque* cadenab[5] = {&b1,&b2,&b3,&b4,0};
    tdt_agregarBloques(t, cadenab);


    //4)
    bloque borrarb1 ={{83,255,170},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}};
    bloque borrarb2 = {{255,255,255},{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}};

    bloque* cadenapborrar[3] = {&borrarb1, &borrarb2, 0};

    tdt_borrarBloques(t, cadenapborrar);


    //5)
    maxmin* mm = tdt_obtenerMaxMin(t);
    imprimir(mm->max_clave,3);
    imprimir(mm->min_clave,3);
    imprimir(mm->max_valor,15);
    imprimir(mm->min_valor,15);


    //6)
    printf("\n");
    tdt_imprimirTraducciones(t, stdout);


    //7)
    printf("\n");
    printf("Cantidad: %d\n", t->cantidad);


    //8)
    free(mm);
    tdt_destruir(&(t));

    return 0;
}


void imprimir(uint8_t* v, int cant){
	int i;
	for(i = 0; i < cant; i++){
		printf("%02X", v[i]);
	}
	printf("\n");
}