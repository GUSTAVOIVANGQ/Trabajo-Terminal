// Código C generado automáticamente a partir del diagrama de flujo
// Generado el 2026-05-05 21:29:10.792220

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

int main() {
    // Proceso: int arr[5]
    int arr[5];
    // Proceso: int temp, i, j
    int temp, i, j;
    // Bucle: for (i = 0; i < 5; i++)
    for (i = 0; i < 5; i++) {
        // Entrada: Leer arr[i]
        printf("Ingrese arr: "); fflush(stdout); scanf("%d", &arr[i]);
    }
    // Bucle: for (i = 0; i < 4; i++)
    for (i = 0; i < 4; i++) {
        // Bucle: for (j = 0; j < 4-i; j++)
        for (j = 0; j < 4-i; j++) {
            // Decisión: arr[j] > arr[j+1]
            if (arr[j] > arr[j+1]) {
                // Proceso: temp = arr[j]
                temp = arr[j];
                arr[j] = arr[j+1];
                arr[j+1] = temp;
            }
        }
    }
    // Salida: Escribir "Arreglo ordenado:"
    printf("Arreglo ordenado:\n");
    // Bucle: for (i = 0; i < 5; i++)
    for (i = 0; i < 5; i++) {
        // Salida: Escribir arr[i]
        printf("%d\n", arr[i]);
    }
    // Fin del programa

    return 0;
}
