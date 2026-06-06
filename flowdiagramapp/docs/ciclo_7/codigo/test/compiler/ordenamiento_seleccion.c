// Código C generado automáticamente a partir del diagrama de flujo
// Generado el 2026-05-31 16:47:20.993766

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

int main() {
  int arr[5];
  int minIdx, temp, i, j;

  // Inicio del programa
  // Bucle: for (i = 0; i < 5; i++)
  for (i = 0; i < 5; i++) {
    // Dato: Leer arr[i]
    scanf("%d", &arr[i]);
  }
  // Bucle: for (i = 0; i < 4; i++)
  for (i = 0; i < 4; i++) {
    // Proceso: minIdx = i
    minIdx = i;
    // Bucle: for (j = i+1; j < 5; j++)
    for (j = i+1; j < 5; j++) {
      // Decisión: arr[j] < arr[minIdx]
      if (arr[j] < arr[minIdx]) {
        // Proceso: minIdx = j
        minIdx = j;
      }
    }
    // Decisión: minIdx != i
    if (minIdx != i) {
      // Proceso: temp = arr[i] arr[i] = arr[minIdx] arr[minIdx] = temp
      temp = arr[i];
      arr[i] = arr[minIdx];
      arr[minIdx] = temp;
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
