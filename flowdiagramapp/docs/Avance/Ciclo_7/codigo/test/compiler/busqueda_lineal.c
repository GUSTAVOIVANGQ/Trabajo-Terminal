// Código C generado automáticamente a partir del diagrama de flujo
// Generado el 2026-05-05 20:40:36.268123

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

int main() {
    // Proceso: int valorBuscado, encontrado, posicion, i
    int valorBuscado, encontrado, posicion, i;
    // Proceso: int arr[5] = {10, 25, 8, 42, 17}
    int arr[5] = {10, 25, 8, 42, 17};
    // Entrada: Leer valorBuscado
    printf("Ingrese valorBuscado: "); scanf("%d", &valorBuscado);
    // Proceso: encontrado = 0
    encontrado = 0;
    // Proceso: posicion = -1
    posicion = -1;
    // Bucle: for (i = 0; i < 5; i++)
    for (i = 0; i < 5; i++) {
        // Decisión: arr[i] == valorBuscado
        if(arr[i] == valorBuscado) {
            // Proceso: encontrado = 1
            encontrado = 1;
            posicion = i;
        }
    }
    // Decisión: encontrado == 1
    if (encontrado == 1) {
        // Salida: Mostrar posicion
        printf("%d\n", posicion);
        // Fin del programa
    } else {
        // Salida: Escribir "No encontrado"
        printf("No encontrado\n");
        // Fin del programa
    }

    return 0;
}
