// Ejemplo de código C generado por el nodo de bucle
// Generado automáticamente a partir del diagrama de flujo

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

// Declaración de variables
int contador = 0;

int main() {
    // Proceso: Inicio
    
    // Inicialización de variable: int contador = 0
    contador = 0;
    
    // Entrada: Ingrese el límite
    int limite;
    printf("Ingrese el límite: ");
    scanf("%d", &limite);
    
    // Bucle: while(contador < limite)
    while (contador < limite) {
        // Salida: Mostrar contador
        printf("Contador: %d\n", contador);
        
        // Proceso: contador = contador + 1
        contador = contador + 1;
    }
    
    // Salida: Mostrar 'Bucle terminado'
    printf("Bucle terminado\n");
    
    // Fin del programa

    return 0;
}
