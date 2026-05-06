// Código C generado automáticamente a partir del diagrama de flujo
// Generado el 2026-05-05 21:11:28.391677

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

int main() {
    // Proceso: int arr[5]
    int arr[5];
    // Proceso: int minIdx, temp, i, j
    int minIdx, temp, i, j;
    // Bucle: for (i = 0; i < 5; i++)
    for (i = 0; i < 5; i++) {
        // Entrada: Leer arr[i]
        printf("Ingrese arr: "); scanf("%d", &arr);
    }
    // Bucle: for (i = 0; i < 4; i++)
    for (i = 0; i < 4; i++) {
        // Proceso: minIdx = i
        minIdx = i;
        // Bucle: for (j = i+1; j < 5; j++)
        for (j = i+1; j < 5; j++) {
            // Decisión: arr[j] < arr[minIdx]
            while (arr[j] < arr[minIdx]) {
                // Proceso: minIdx = j
                minIdx = j;
            }
            // Decisión: minIdx != i
            while (minIdx != i) {
                // Proceso: temp = arr[i]
                temp = arr[i];
                arr[i] = arr[minIdx];
                arr[minIdx] = temp;
            }
        }
    }
    // Salida: Escribir "Arreglo ordenado:"
    printf("Arreglo ordenado:\n");
    // Bucle: for (i = 0; i < 5; i++)
    for (i = 0; i < 5; i++) {
        // Salida: Escribir arr[i]
        printf("arr[i]\n");
    }
    // Fin del programa

    return 0;
}
