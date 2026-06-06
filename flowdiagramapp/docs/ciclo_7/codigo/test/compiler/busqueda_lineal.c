// Código C generado automáticamente a partir del diagrama de flujo
// Generado el 2026-05-31 16:27:23.695989

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

int main() {
  int valorBuscado, encontrado, posicion, i;

  // Inicio del programa
  // Proceso: int arr[5] = {10, 25, 8, 42, 17}
  int arr[5] = {10, 25, 8, 42, 17};
  // Dato: Leer valorBuscado
  scanf("%d", &valorBuscado);
  // Proceso: encontrado = 0
  encontrado = 0;
  // Proceso: posicion = -1
  posicion = -1;
  // Bucle: for (i = 0; i < 5; i++)
  for (i = 0; i < 5; i++) {
    // Decisión: arr[i] == valorBuscado
    if (arr[i] == valorBuscado) {
      // Proceso: encontrado = 1
      encontrado = 1;
      // Proceso: posicion = i
      posicion = i;
    }
  }
  // Decisión: encontrado == 1
  if (encontrado == 1) {
    // Dato: Escribir "Encontrado en posición:", posicion
    printf("Encontrado en posición: %d\n", posicion);
  }
  else {
    // Dato: Escribir "No encontrado"
    printf("No encontrado\n");
  }

  return 0;
}
