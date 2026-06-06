// Código C generado automáticamente a partir del diagrama de flujo
// Generado el 2026-05-05 20:10:10.240814

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

int main() {
    // Proceso: int n, factorial, i
    int n, factorial, i;
    // Entrada: Leer n
    printf("Ingrese n: "); scanf("%d", &n);
    // Proceso: factorial = 1
    factorial = 1;
    // Bucle: for (i = 1; i <= n; i++)
    for (i = 1; i <= n; i++) {
        // Proceso: factorial = factorial * i
        factorial = factorial * i;
    }
    // Salida: Escribir "Factorial:", factorial
    printf("Factorial: %d\n", factorial);
    // Fin del programa

    return 0;
}
