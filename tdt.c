#include "tdt.h"

tdtN1* crearTdtn1();
tdtN2* crearTdtn2();
tdtN3* crearTdtn3();


/********** FUNCIONES DEL TP ***********/

void tdt_agregar(tdt* tabla, uint8_t* clave, uint8_t* valor) {
	int i;

	tdtN3* tercera;

	//reviso si estan las 3 tablas, sino las creo
	if (tabla->primera != NULL){
		//la primera tabla tdtn1 existe ya
		tdtN2* segunda = tabla->primera->entradas[clave[0]];

		if(segunda != NULL){
			//la segunda tabla tdtn2 existe ya
			tercera = segunda->entradas[clave[1]];
			
			if(tercera == NULL){
				//la tercera tabla tdtn3 no existe, la creo y hago que apunte la segunda
				tercera = crearTdtn3();
				segunda->entradas[clave[1]] = tercera;
				//a cantidad le agrego uno
				tabla->cantidad++;

			} else if(tercera != NULL && tercera->entradas[clave[2]].valido == 0) {
				//a cantidad le agrego uno
				tabla->cantidad++;
			}
			

		} else {
			//la segunda tabla no existe, por ende la tercera tampoco
			//creo las 2 tablas
			segunda = crearTdtn2();
			tercera = crearTdtn3();

			//conecto los nodos
			tabla->primera->entradas[clave[0]] = segunda;
			segunda->entradas[clave[1]] = tercera;

			//a cantidad le agrego uno
			tabla->cantidad++;
		}

	} else {
		//no existe la primer tabla, por ende no existe ninguna
		//creo las 3 tablas
		tabla->primera = crearTdtn1();
		tabla->primera->entradas[clave[0]] = crearTdtn2();
		tabla->primera->entradas[clave[0]]->entradas[clave[1]] = crearTdtn3();
		
		//a cantidad le agrego uno
		tabla->cantidad++;
	}

	//inserto los valores

	for(i = 0; i < 15; i++){
		tabla->primera->entradas[clave[0]]->entradas[clave[1]]->entradas[clave[2]].valor.val[i] = valor[i];
	}
	
	tabla->primera->entradas[clave[0]]->entradas[clave[1]]->entradas[clave[2]].valido = 1;
}

void tdt_borrar(tdt* tabla, uint8_t* clave) {
	int i;

	//si no existe la primera tabla no hay nada que borrar
	if (tabla->primera != NULL){
		tdtN1* primera = tabla->primera;
		tdtN2* segunda = NULL;
		tdtN3* tercera = NULL;

		//tiene que existir la segunda tabla para borrar
		if(tabla->primera->entradas[clave[0]] != NULL){
			segunda = tabla->primera->entradas[clave[0]];

			// miro si existe la tercer tabla
			if(segunda->entradas[clave[1]] != NULL){
				tercera = segunda->entradas[clave[1]];

				//si es valido lo invalido
				if(tercera->entradas[clave[2]].valido != 0){
					tercera->entradas[clave[2]].valido = 0;
					tabla->cantidad--;
				}
			}
		}

		//ahora miro las tablas, si estan vacias las borro
		//miro la tercer tabla
		if(tercera != NULL){

			//miro si todos los valores no son validos
			i = 0;
			while(i < 256 && tercera->entradas[i].valido == 0) i++;

			//si i == 256 la tabla está vacia, se tiene que borrar
			if(i == 256){
				//hago null la entrada de segunda y borro la tercer tabla
				segunda->entradas[clave[1]] = NULL;
				//printf("free tercera %p\n",tercera);
				free(tercera);

				//reviso la segunda tabla si tiene todo null para borrarla.
				i = 0;
				while(i < 256 && segunda->entradas[i] == NULL) i++;

				//si i == 256 entonces la segunda tabla esta vacia y hay que borrarla
				if(i == 256){
					//hago null la entrada de la primera y borro la segunda tabla
					primera->entradas[clave[0]] = NULL;
					//printf("free segunda %p\n",segunda);
					free(segunda);

					//miro la primer tabla si es tiene todo null para borrarla.
					i = 0;
					while(i < 256 && primera->entradas[i] == NULL) i++;

					//si i == 256 tiene todo null y hay que borrarla
					if(i == 256){
						//hago null el puntero a la primer tabla y la borro
						tabla->primera = NULL;
						//printf("free primera %p\n",primera);
						free(primera);
					}
				}
			}

		}
		//no reviso el caso que la tercer tabla sea null ya que no borre nada.
	}
}

void tdt_imprimirTraducciones(tdt* tabla, FILE *pFile) {
	int i,j,k,n;
	
	//pongo la identificacion
	fprintf(pFile, "%s %s %s\n","-", tabla->identificacion, "-");

	if(tabla->primera != NULL){
		i = 0;
		j = 0;
		k = 0;
		//busco en la primer tabla
		for(i = 0; i < 256; i++){
			tdtN2* segunda = tabla->primera->entradas[i];
			j = 0;
	
			if(segunda != NULL){
				j = 0;
				
				for(j = 0; j < 256; j++){
					tdtN3* tercera =  segunda->entradas[j];
					if(tercera != NULL){
						k = 0;
						for(k = 0; k < 256; k++){
							if(tercera->entradas[k].valido != 0){
								n=0;
								fprintf(pFile, "%02X%02X%02X %s ",i,j,k, "=>");

								for(n=0;n < 15; n++){
									fprintf(pFile, "%02X", tercera->entradas[k].valor.val[n]);
								}
								fprintf(pFile, "\n");
							}
						}
					}
	
				}
			}
		}
	}

}

maxmin* tdt_obtenerMaxMin(tdt* tabla) {
	maxmin* mm = malloc(sizeof(maxmin));
	tdtN1* primera;
	tdtN2* segunda;
	tdtN3* tercera;

	//uint8_t cla_cero,cla_uno,cla_dos;
	int i,j,k,ciclo;


	for(i = 0; i < 15; i++){
		if(i < 3) {
			mm->max_clave[i] = 0;
			mm->min_clave[i] = 255;
		}

		mm->max_valor[i] = 0;
		mm->min_valor[i] = 255;
	}

	primera = tabla->primera;
	//tiene que existir la primer tabla
	if(primera != NULL){
		//recorro la primer tabla

		for(i = 0; i < 256; i++){
			segunda = primera->entradas[i];

			//si hay tabla segunda en posicion la recorro
			if(segunda != NULL){
				
				//recorro la segunda tabla
				for(j = 0; j < 256; j++){
					tercera = segunda->entradas[j];

					//si hay tercer tabla la recorro comparando
					if(tercera != NULL){
						
						//recorro la tercer tabla y comparo
						for(k = 0; k < 256; k++){
							if(tercera->entradas[k].valido != 0){
								//si el valor es valido comparo el valor y la clave
								
								//mayor clave
								if( (i > mm->max_clave[0]) || 
	  					   		    (i == mm->max_clave[0] && j > mm->max_clave[1]) || 
	  							    (i == mm->max_clave[0] && j == mm->max_clave[1] && k > mm->max_clave[2]) ) {
									mm->max_clave[0] = i;
									mm->max_clave[1] = j;
									mm->max_clave[2] = k;
								}

								//menor clave
								if( (i < mm->min_clave[0]) || 
	  					   		    (i == mm->min_clave[0] && j < mm->min_clave[1]) || 
	  							    (i == mm->min_clave[0] && j == mm->min_clave[1] && k < mm->min_clave[2]) ){
										mm->min_clave[0] = i;
										mm->min_clave[1] = j;
										mm->min_clave[2] = k;
								}

								//busco si es mayor
								ciclo = 0;
								while(ciclo < 15 && tercera->entradas[k].valor.val[ciclo] == mm->max_valor[ciclo]){
									ciclo++;
								}

								//mayor valor
								if(ciclo != 15 && tercera->entradas[k].valor.val[ciclo] > mm->max_valor[ciclo]){
									for (ciclo = 0; ciclo < 15; ++ciclo) {
										mm->max_valor[ciclo] = tercera->entradas[k].valor.val[ciclo];
									}
								}

								//busco si es menor
								ciclo = 0;
								while(ciclo < 15 && tercera->entradas[k].valor.val[ciclo] == mm->min_valor[ciclo]){
									ciclo++;
								}

								//menor valor
								if(ciclo != 15 && tercera->entradas[k].valor.val[ciclo] < mm->min_valor[ciclo]){
									for (ciclo = 0; ciclo < 15; ++ciclo) {
										mm->min_valor[ciclo] = tercera->entradas[k].valor.val[ciclo];
									}
								}
							}

						}//end for que recorre la tercer tabla
					}
						
				}//end for que recorre la segunda tabla
			}

		}//end for que recorre la primer tabla
	}

	return mm;
}


/***************** FUNCIONES AUXILIARES *********************/

tdtN1* crearTdtn1(){
	int i;
	//creo la primer tabla y la inicializo en null
	tdtN1* primerat = malloc(sizeof(tdtN1));

	for(i = 0; i < 256; i++){
		primerat->entradas[i] = NULL;
	}

	return primerat;
}

tdtN2* crearTdtn2(){
	int i;
	//creo la segunda tabla y la inicializo en null
	tdtN2* segundat = malloc(sizeof(tdtN2));

	for (i = 0; i < 256; i++){
		segundat->entradas[i] = NULL;
	}

	return segundat;
}

tdtN3* crearTdtn3(){
	int i;
	//creo la tercer tabla y la inicializo con valido en 0
	tdtN3* tercerat = malloc(sizeof(tdtN3));

	for (i = 0; i < 256; i++){
		tercerat->entradas[i].valido = 0;
	}

	return tercerat;
}

