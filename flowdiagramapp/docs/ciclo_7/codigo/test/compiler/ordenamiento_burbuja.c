// Código C generado automáticamente a partir del diagrama de flujo
// Generado el 2026-05-31 16:53:54.771940

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

int main() {
  int arr[5];
  int temp, i, j;

  // Inicio del programa
  // Bucle: for (i = 0; i < 5; i++)
  for (i = 0; i < 5; i++) {
    // Dato: Leer arr[i]
    scanf("%d", &arr[i]);
  }
  // Bucle: for (i = 0; i < 4; i++)
  for (i = 0; i < 4; i++) {
    // Bucle: for (j = 0; j < 4-i; j++)
    for (j = 0; j < 4-i; j++) {
      // Decisión: arr[j] > arr[j+1]
      if (arr[j] > arr[j+1]) {
        // Proceso: temp = arr[j] arr[j] = arr[j+1] arr[j+1] = temp
        temp = arr[j];
        arr[j] = arr[j+1];
        arr[j+1] = temp;
      }
    }
  }
  // Dato: Escribir "Arreglo ordenado:"
  printf("Arreglo ordenado:\n");
  // Bucle: for (i = 0; i < 5; i++)
  for (i = 0; i < 5; i++) {
    // Dato: Escribir arr[i]
    printf("%d\n", arr[i]);
  }

  return 0;
}
