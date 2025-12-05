import 'package:shared_preferences/shared_preferences.dart';
import '../models/tutorial_step.dart';

/// Servicio para gestionar el estado y progreso del tutorial
class TutorialService {
  static const String _keyFirstTime = 'tutorial_first_time';
  static const String _keyCompletedTutorials = 'tutorial_completed_';

  /// Verifica si es la primera vez que el usuario usa la app
  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstTime) ?? true;
  }

  /// Marca que el usuario ya ha visto el tutorial inicial
  Future<void> markFirstTimeComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstTime, false);
  }

  /// Verifica si un tutorial específico ha sido completado
  Future<bool> isTutorialCompleted(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_keyCompletedTutorials$tutorialId') ?? false;
  }

  /// Marca un tutorial como completado
  Future<void> markTutorialComplete(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_keyCompletedTutorials$tutorialId', true);
  }

  /// Reinicia el progreso del tutorial (útil para testing)
  Future<void> resetTutorialProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstTime, true);
    // Limpiar todos los tutoriales completados
    final keys = prefs.getKeys();
    for (var key in keys) {
      if (key.startsWith(_keyCompletedTutorials)) {
        await prefs.remove(key);
      }
    }
  }

  /// Obtiene todos los tutoriales disponibles
  List<TutorialPage> getAllTutorials() {
    return [
      _getWelcomeTutorial(),
      _getBasicsTutorial(),
      _getStartNodeTutorial(),
      _getEndNodeTutorial(),
      _getProcessNodeTutorial(),
      _getDecisionNodeTutorial(),
      _getInputNodeTutorial(),
      _getOutputNodeTutorial(),
      _getVariableNodeTutorial(),
      _getLoopNodeTutorial(),
      _getConnectorNodeTutorial(),
      _getCommentNodeTutorial(),
      _getSubprocessNodeTutorial(),
      _getConnectionsTutorial(),
      _getValidationTutorial(),
      _getCodeGenerationTutorial(),
    ];
  }

  /// Tutorial de bienvenida
  TutorialPage _getWelcomeTutorial() {
    return TutorialPage(
      id: 'welcome',
      title: '¡Bienvenido a FlowDiagram App!',
      subtitle: 'Aprende a crear algoritmos de forma visual',
      category: TutorialCategory.welcome,
      estimatedMinutes: 3,
      steps: [
        TutorialStep(
          title: '¿Qué es un diagrama de flujo?',
          description:
              'Un diagrama de flujo es una representación visual de un algoritmo o proceso. Utiliza símbolos estándar conectados por flechas para mostrar el orden de las operaciones.',
          keyPoints: [
            'Representación visual de algoritmos',
            'Fácil de entender y comunicar',
            'Ayuda a identificar errores lógicos',
          ],
        ),
        TutorialStep(
          title: '¿Qué puedes hacer aquí?',
          description:
              'Con esta aplicación podrás:\n\n• Diseñar algoritmos usando símbolos visuales\n• Generar código en lenguaje C automáticamente\n• Validar la estructura de tus diagramas\n• Guardar y cargar tus proyectos',
          keyPoints: [
            'Editor visual intuitivo',
            'Generación automática de código',
            'Validación en tiempo real',
          ],
        ),
        TutorialStep(
          title: 'Taxonomía de Bloom - Nivel: Comprensión',
          description:
              'Esta aplicación te ayudará a COMPRENDER los conceptos básicos de programación. Aprenderás a:\n\n• Identificar diferentes tipos de operaciones\n• Distinguir entre estructuras de control\n• Comparar diferentes enfoques algorítmicos\n• Explicar el flujo de ejecución',
          keyPoints: [
            'Identificar: Reconocer símbolos y su función',
            'Distinguir: Diferenciar tipos de operaciones',
            'Comparar: Analizar diferentes soluciones',
          ],
        ),
        TutorialStep(
          title: '¿Listo para empezar?',
          description:
              'A continuación, explorarás los conceptos básicos y cada tipo de nodo disponible. ¡Tómate tu tiempo y practica!',
          keyPoints: [
            'Aprende a tu propio ritmo',
            'Practica con ejemplos',
            'Consulta el tutorial cuando lo necesites',
          ],
        ),
      ],
    );
  }

  /// Tutorial de conceptos básicos
  TutorialPage _getBasicsTutorial() {
    return TutorialPage(
      id: 'basics',
      title: 'Conceptos Básicos',
      subtitle: 'Fundamentos de los diagramas de flujo',
      category: TutorialCategory.basics,
      estimatedMinutes: 5,
      steps: [
        TutorialStep(
          title: 'Flujo de Ejecución',
          description:
              'Los diagramas de flujo se leen de arriba hacia abajo y de izquierda a derecha. El flujo de ejecución sigue las flechas que conectan los símbolos.',
          keyPoints: [
            'Inicio: Todo diagrama comienza con un nodo de inicio',
            'Secuencia: Las operaciones se ejecutan en orden',
            'Fin: Todo diagrama termina con un nodo de fin',
          ],
        ),
        TutorialStep(
          title: 'Tipos de Operaciones',
          description:
              'Existen diferentes tipos de operaciones en un algoritmo:\n\n• Entrada: Recibir datos del usuario\n• Proceso: Realizar cálculos o transformaciones\n• Decisión: Elegir entre diferentes caminos\n• Salida: Mostrar resultados',
          keyPoints: [
            'Entrada: Leer datos',
            'Proceso: Calcular',
            'Decisión: Elegir',
            'Salida: Mostrar',
          ],
        ),
        TutorialStep(
          title: 'Conexiones',
          description:
              'Las flechas conectan los símbolos y muestran el orden de ejecución. Cada flecha puede tener una etiqueta que indica una condición o el tipo de salida.',
          keyPoints: [
            'Las flechas indican el orden',
            'Las etiquetas especifican condiciones',
            'Todo nodo debe estar conectado',
          ],
        ),
      ],
    );
  }

  /// Tutorial del nodo de inicio
  TutorialPage _getStartNodeTutorial() {
    return TutorialPage(
      id: 'node_start',
      title: 'Nodo de Inicio',
      subtitle: 'Símbolo: Óvalo verde',
      category: TutorialCategory.nodes,
      estimatedMinutes: 2,
      steps: [
        TutorialStep(
          title: 'Identifica el Nodo de Inicio',
          description:
              'El nodo de inicio es un óvalo verde que marca el comienzo de tu algoritmo. Es el primer símbolo que se ejecuta.',
          nodeType: 'start',
          keyPoints: [
            'Forma: Óvalo',
            'Color: Verde',
            'Posición: Al principio del diagrama',
            'Conexiones: Solo tiene salidas, no entradas',
          ],
        ),
        TutorialStep(
          title: 'Reglas del Nodo de Inicio',
          description:
              'Todo diagrama DEBE tener exactamente un nodo de inicio. No puede tener más de uno ni puede faltar.',
          keyPoints: [
            'Obligatorio: Debe existir',
            'Único: Solo uno por diagrama',
            'Sin entradas: No recibe conexiones de entrada',
          ],
          example: 'INICIO\n  ↓\n(siguiente operación)',
        ),
      ],
    );
  }

  /// Tutorial del nodo de fin
  TutorialPage _getEndNodeTutorial() {
    return TutorialPage(
      id: 'node_end',
      title: 'Nodo de Fin',
      subtitle: 'Símbolo: Óvalo rojo',
      category: TutorialCategory.nodes,
      estimatedMinutes: 2,
      steps: [
        TutorialStep(
          title: 'Identifica el Nodo de Fin',
          description:
              'El nodo de fin es un óvalo rojo que marca el final de tu algoritmo. Indica que el programa ha terminado.',
          nodeType: 'end',
          keyPoints: [
            'Forma: Óvalo',
            'Color: Rojo',
            'Posición: Al final del diagrama',
            'Conexiones: Solo tiene entradas, no salidas',
          ],
        ),
        TutorialStep(
          title: 'Reglas del Nodo de Fin',
          description:
              'Todo diagrama DEBE tener al menos un nodo de fin. Puede tener varios si hay múltiples puntos de salida.',
          keyPoints: [
            'Obligatorio: Debe existir al menos uno',
            'Múltiple: Puede haber varios',
            'Sin salidas: No tiene conexiones de salida',
          ],
          example: '(operación anterior)\n  ↓\n FIN',
        ),
      ],
    );
  }

  /// Tutorial del nodo de proceso
  TutorialPage _getProcessNodeTutorial() {
    return TutorialPage(
      id: 'node_process',
      title: 'Nodo de Proceso',
      subtitle: 'Símbolo: Rectángulo azul',
      category: TutorialCategory.nodes,
      estimatedMinutes: 4,
      steps: [
        TutorialStep(
          title: 'Identifica el Nodo de Proceso',
          description:
              'El nodo de proceso es un rectángulo azul que representa operaciones de cálculo, asignaciones o transformaciones de datos.',
          nodeType: 'process',
          keyPoints: [
            'Forma: Rectángulo',
            'Color: Azul',
            'Uso: Operaciones y cálculos',
          ],
        ),
        TutorialStep(
          title: 'Tipos de Operaciones',
          description:
              'Un nodo de proceso puede realizar:\n\n• Asignaciones: edad = 25\n• Operaciones matemáticas: suma = a + b\n• Incrementos: contador = contador + 1\n• Decrementos: contador = contador - 1',
          keyPoints: [
            'Asignación simple',
            'Operaciones aritméticas (+, -, *, /, %)',
            'Modificación de variables',
          ],
          example: 'suma = a + b\nresultado = suma * 2',
        ),
        TutorialStep(
          title: 'Distingue entre Asignación y Comparación',
          description:
              'IMPORTANTE: No confundas:\n\n• = (asignación): Guarda un valor en una variable\n• == (comparación): Compara dos valores (se usa en decisiones)',
          keyPoints: [
            'Asignación (=): Para guardar valores',
            'Comparación (==): Para condiciones',
            'El proceso usa asignación (=)',
          ],
        ),
      ],
    );
  }

  /// Tutorial del nodo de decisión
  TutorialPage _getDecisionNodeTutorial() {
    return TutorialPage(
      id: 'node_decision',
      title: 'Nodo de Decisión',
      subtitle: 'Símbolo: Rombo naranja',
      category: TutorialCategory.nodes,
      estimatedMinutes: 5,
      steps: [
        TutorialStep(
          title: 'Identifica el Nodo de Decisión',
          description:
              'El nodo de decisión es un rombo naranja que representa una pregunta o condición. Permite que el programa tome diferentes caminos según la respuesta.',
          nodeType: 'decision',
          keyPoints: [
            'Forma: Rombo',
            'Color: Naranja',
            'Uso: Preguntas y condiciones',
            'Salidas: Múltiples caminos (Sí/No, Verdadero/Falso)',
          ],
        ),
        TutorialStep(
          title: 'Tipos de Condiciones',
          description:
              'Puedes hacer diferentes tipos de preguntas:\n\n• Comparación: ¿edad > 18?\n• Igualdad: ¿nombre == "Juan"?\n• Rango: ¿10 < edad < 20?\n• Existencia: ¿variable existe?\n• Lógicas: ¿edad > 18 Y salario > 1000?',
          keyPoints: [
            'Comparación: >, <, >=, <=',
            'Igualdad: ==, !=',
            'Lógica: Y (&&), O (||), NO (!)',
          ],
        ),
        TutorialStep(
          title: 'Compara Operadores Lógicos',
          description:
              'Los operadores lógicos combinan condiciones:\n\n• Y (&&): Ambas condiciones deben ser verdaderas\n• O (||): Al menos una condición debe ser verdadera\n• NO (!): Invierte el resultado',
          keyPoints: [
            'Y (&&): Todas verdaderas',
            'O (||): Al menos una verdadera',
            'NO (!): Invierte el resultado',
          ],
          example: '¿edad >= 18 Y salario > 1000?\n  ↙ Sí    No ↘',
        ),
      ],
    );
  }

  /// Tutorial del nodo de entrada
  TutorialPage _getInputNodeTutorial() {
    return TutorialPage(
      id: 'node_input',
      title: 'Nodo de Entrada',
      subtitle: 'Símbolo: Paralelogramo verde',
      category: TutorialCategory.nodes,
      estimatedMinutes: 3,
      steps: [
        TutorialStep(
          title: 'Identifica el Nodo de Entrada',
          description:
              'El nodo de entrada es un paralelogramo verde inclinado hacia la derecha. Se usa para leer datos del usuario o de un archivo.',
          nodeType: 'input',
          keyPoints: [
            'Forma: Paralelogramo (→)',
            'Color: Verde',
            'Uso: Leer datos del usuario',
          ],
        ),
        TutorialStep(
          title: 'Tipos de Entrada',
          description:
              'Puedes leer diferentes tipos de datos:\n\n• Enteros: Leer edad\n• Decimales: Leer precio\n• Texto: Leer nombre\n• Múltiples valores: Leer a, b, c',
          keyPoints: [
            'Leer un valor',
            'Leer múltiples valores',
            'Especificar tipo de dato',
          ],
          example: 'Leer edad\nLeer nombre, apellido',
        ),
        TutorialStep(
          title: 'Distingue Entrada de Salida',
          description:
              'No confundas:\n\n• Entrada (→): El usuario INGRESA datos\n• Salida (←): El programa MUESTRA datos',
          keyPoints: [
            'Entrada: Usuario → Programa',
            'Salida: Programa → Usuario',
            'Direcciones opuestas',
          ],
        ),
      ],
    );
  }

  /// Tutorial del nodo de salida
  TutorialPage _getOutputNodeTutorial() {
    return TutorialPage(
      id: 'node_output',
      title: 'Nodo de Salida',
      subtitle: 'Símbolo: Paralelogramo azul',
      category: TutorialCategory.nodes,
      estimatedMinutes: 3,
      steps: [
        TutorialStep(
          title: 'Identifica el Nodo de Salida',
          description:
              'El nodo de salida es un paralelogramo azul inclinado hacia la izquierda. Se usa para mostrar resultados al usuario o escribir en un archivo.',
          nodeType: 'output',
          keyPoints: [
            'Forma: Paralelogramo (←)',
            'Color: Azul',
            'Uso: Mostrar resultados',
          ],
        ),
        TutorialStep(
          title: 'Tipos de Salida',
          description:
              'Puedes mostrar:\n\n• Mensajes: Mostrar "Hola Mundo"\n• Variables: Mostrar resultado\n• Expresiones: Mostrar a + b\n• Múltiples valores: Mostrar nombre, edad',
          keyPoints: [
            'Mostrar mensajes',
            'Mostrar variables',
            'Mostrar resultados de cálculos',
          ],
          example: 'Mostrar "La suma es:"\nMostrar suma',
        ),
      ],
    );
  }

  /// Tutorial del nodo de variable
  TutorialPage _getVariableNodeTutorial() {
    return TutorialPage(
      id: 'node_variable',
      title: 'Nodo de Variable',
      subtitle: 'Símbolo: Hexágono morado',
      category: TutorialCategory.nodes,
      estimatedMinutes: 4,
      steps: [
        TutorialStep(
          title: 'Identifica el Nodo de Variable',
          description:
              'El nodo de variable es un hexágono morado que se usa para declarar variables antes de usarlas en el programa.',
          nodeType: 'variable',
          keyPoints: [
            'Forma: Hexágono',
            'Color: Morado',
            'Uso: Declarar variables',
          ],
        ),
        TutorialStep(
          title: 'Tipos de Declaración',
          description:
              'Puedes declarar:\n\n• Variable simple: int edad\n• Con inicialización: int edad = 0\n• Constante: const float PI = 3.14159\n• Arreglo: int numeros[10]',
          keyPoints: [
            'Declarar sin valor inicial',
            'Declarar con valor inicial',
            'Declarar constantes',
            'Declarar arreglos',
          ],
        ),
        TutorialStep(
          title: 'Compara Tipos de Datos',
          description:
              'Tipos de datos disponibles:\n\n• int: Números enteros (1, 2, 100)\n• float: Decimales (3.14, 2.5)\n• char: Caracteres (\'a\', \'X\')\n• bool: Verdadero/Falso\n• string: Texto ("Hola")',
          keyPoints: [
            'int: Enteros sin decimales',
            'float/double: Números con decimales',
            'char: Un solo carácter',
            'bool: true o false',
          ],
          example: 'int edad = 0\nfloat precio = 19.99\nchar letra = \'A\'',
        ),
      ],
    );
  }

  /// Tutorial del nodo de bucle
  TutorialPage _getLoopNodeTutorial() {
    return TutorialPage(
      id: 'node_loop',
      title: 'Nodo de Preparación/Bucle',
      subtitle: 'Símbolo: Hexágono amarillo',
      category: TutorialCategory.nodes,
      estimatedMinutes: 5,
      steps: [
        TutorialStep(
          title: 'Identifica el Nodo de Preparación',
          description:
              'El nodo de preparación es un hexágono amarillo usado para inicializar contadores y configurar bucles (ciclos repetitivos).',
          nodeType: 'loop',
          keyPoints: [
            'Forma: Hexágono',
            'Color: Amarillo',
            'Uso: Inicialización y bucles',
          ],
        ),
        TutorialStep(
          title: 'Tipos de Bucles',
          description:
              'Existen diferentes formas de repetir operaciones:\n\n• FOR: Repetir un número conocido de veces\n• WHILE: Repetir mientras una condición sea verdadera\n• DO-WHILE: Repetir al menos una vez',
          keyPoints: [
            'FOR: Número fijo de repeticiones',
            'WHILE: Condición al inicio',
            'DO-WHILE: Condición al final',
          ],
        ),
        TutorialStep(
          title: 'Distingue los Tipos de Bucle',
          description:
              'Compara las diferencias:\n\n• FOR: "Cuenta del 1 al 10"\n• WHILE: "Mientras haya datos"\n• DO-WHILE: "Hacer al menos una vez"',
          keyPoints: [
            'FOR: Repeticiones contadas',
            'WHILE: Puede no ejecutarse',
            'DO-WHILE: Se ejecuta al menos una vez',
          ],
          example: 'FOR i = 1 TO 10\n  Mostrar i\nFIN FOR',
        ),
      ],
    );
  }

  /// Tutorial del nodo conector
  TutorialPage _getConnectorNodeTutorial() {
    return TutorialPage(
      id: 'node_connector',
      title: 'Nodo Conector',
      subtitle: 'Símbolo: Círculo índigo',
      category: TutorialCategory.nodes,
      estimatedMinutes: 3,
      steps: [
        TutorialStep(
          title: 'Identifica el Nodo Conector',
          description:
              'El nodo conector es un círculo índigo que permite dividir diagramas grandes en secciones. Conecta partes que están en diferentes áreas del diagrama.',
          nodeType: 'connector',
          keyPoints: [
            'Forma: Círculo',
            'Color: Índigo',
            'Uso: Conectar secciones separadas',
          ],
        ),
        TutorialStep(
          title: 'Tipos de Conectores',
          description:
              'Los conectores tienen direcciones:\n\n• Entrada (←): Llega de otra sección\n• Salida (→): Va hacia otra sección\n• Bidireccional (⇄): Ambas direcciones',
          keyPoints: [
            'Entrada: Origen de conexión',
            'Salida: Destino de conexión',
            'Etiqueta: Identificador común',
          ],
          example: '→ A (en una página)\n← A (en otra página)',
        ),
        TutorialStep(
          title: 'Reglas de los Conectores',
          description:
              'Para usar conectores correctamente:\n\n• Usa la misma etiqueta en origen y destino\n• Debe haber al menos 2 conectores con la misma etiqueta\n• Evita ciclos infinitos',
          keyPoints: [
            'Etiquetas coincidentes',
            'Emparejamiento correcto',
            'Evitar bucles infinitos',
          ],
        ),
      ],
    );
  }

  /// Tutorial del nodo de comentario
  TutorialPage _getCommentNodeTutorial() {
    return TutorialPage(
      id: 'node_comment',
      title: 'Nodo de Comentario',
      subtitle: 'Símbolo: Rectángulo con esquina doblada',
      category: TutorialCategory.nodes,
      estimatedMinutes: 2,
      steps: [
        TutorialStep(
          title: 'Identifica el Nodo de Comentario',
          description:
              'El nodo de comentario es un rectángulo amarillo con una esquina doblada. Se usa para agregar notas explicativas al diagrama sin afectar la lógica.',
          nodeType: 'comment',
          keyPoints: [
            'Forma: Rectángulo con esquina doblada',
            'Color: Amarillo',
            'Uso: Documentación y notas',
          ],
        ),
        TutorialStep(
          title: 'Tipos de Comentarios',
          description:
              'Puedes agregar:\n\n• Comentario simple: // Nota breve\n• Comentario de bloque: /* Explicación larga */\n• Comentario de sección: Para organizar\n• Nota importante: NOTA: Información crítica',
          keyPoints: [
            'Documentar el código',
            'Explicar decisiones',
            'Organizar secciones',
          ],
          example: '// Este proceso calcula el total\nMOSTRAR "Hola"',
        ),
      ],
    );
  }

  /// Tutorial del nodo de subproceso
  TutorialPage _getSubprocessNodeTutorial() {
    return TutorialPage(
      id: 'node_subprocess',
      title: 'Nodo de Subproceso',
      subtitle: 'Símbolo: Rectángulo con doble línea',
      category: TutorialCategory.nodes,
      estimatedMinutes: 3,
      steps: [
        TutorialStep(
          title: 'Identifica el Nodo de Subproceso',
          description:
              'El nodo de subproceso es un rectángulo morado con doble línea vertical. Representa una función o procedimiento que se define en otro lugar.',
          nodeType: 'subprocess',
          keyPoints: [
            'Forma: Rectángulo con líneas dobles',
            'Color: Morado',
            'Uso: Llamar funciones',
          ],
        ),
        TutorialStep(
          title: 'Tipos de Subprocesos',
          description:
              'Puedes definir:\n\n• Función sin parámetros: calcularTotal()\n• Función con parámetros: sumar(a, b)\n• Función con retorno: resultado = obtenerValor()',
          keyPoints: [
            'Reutilización de código',
            'Modularización',
            'Parámetros y retornos',
          ],
          example: 'calcularPromedio(notas)\nresultado = obtenerMaximo(lista)',
        ),
      ],
    );
  }

  /// Tutorial de conexiones
  TutorialPage _getConnectionsTutorial() {
    return TutorialPage(
      id: 'connections',
      title: 'Conexiones entre Nodos',
      subtitle: 'Cómo conectar los símbolos',
      category: TutorialCategory.connections,
      estimatedMinutes: 4,
      steps: [
        TutorialStep(
          title: 'Crear Conexiones',
          description:
              'Para conectar nodos:\n\n1. Mantén presionado el primer nodo\n2. Arrastra hacia el nodo destino\n3. Las flechas muestran el orden de ejecución',
          keyPoints: [
            'Mantener presionado',
            'Arrastrar hacia destino',
            'Soltar en el nodo objetivo',
          ],
        ),
        TutorialStep(
          title: 'Etiquetas en Conexiones',
          description:
              'Algunas conexiones necesitan etiquetas:\n\n• Decisiones: "Sí" / "No"\n• Condiciones: "Verdadero" / "Falso"\n• Casos múltiples: "Caso 1", "Caso 2"',
          keyPoints: [
            'Etiquetar salidas de decisiones',
            'Usar etiquetas descriptivas',
            'Mantener consistencia',
          ],
        ),
        TutorialStep(
          title: 'Reglas de Conexión',
          description:
              'Reglas importantes:\n\n• Inicio: Solo tiene salidas\n• Fin: Solo tiene entradas\n• Decisión: Debe tener múltiples salidas\n• Otros: Pueden tener entradas y salidas',
          keyPoints: [
            'Inicio: Sin entradas',
            'Fin: Sin salidas',
            'Decisión: Múltiples salidas',
          ],
        ),
      ],
    );
  }

  /// Tutorial de validación
  TutorialPage _getValidationTutorial() {
    return TutorialPage(
      id: 'validation',
      title: 'Validación de Diagramas',
      subtitle: 'Verifica que tu diagrama sea correcto',
      category: TutorialCategory.validation,
      estimatedMinutes: 4,
      steps: [
        TutorialStep(
          title: '¿Qué es la Validación?',
          description:
              'La validación verifica que tu diagrama siga las reglas lógicas y estructurales de los diagramas de flujo.',
          keyPoints: [
            'Verificación automática',
            'Detección de errores',
            'Sugerencias de corrección',
          ],
        ),
        TutorialStep(
          title: 'Errores Comunes',
          description:
              'El validador detecta:\n\n• Falta de nodo de inicio o fin\n• Nodos sin conexiones\n• Decisiones sin múltiples salidas\n• Bucles infinitos\n• Conectores sin emparejar',
          keyPoints: [
            'Errores estructurales',
            'Errores lógicos',
            'Advertencias de estilo',
          ],
        ),
        TutorialStep(
          title: 'Identificar y Corregir Errores',
          description:
              'Cuando valides tu diagrama:\n\n1. Lee el mensaje de error\n2. Identifica el nodo problemático\n3. Corrige según las sugerencias\n4. Valida nuevamente',
          keyPoints: [
            'Leer mensajes con atención',
            'Corregir uno a uno',
            'Validar después de cada cambio',
          ],
        ),
      ],
    );
  }

  /// Tutorial de generación de código
  TutorialPage _getCodeGenerationTutorial() {
    return TutorialPage(
      id: 'code_generation',
      title: 'Generación de Código',
      subtitle: 'De diagrama a código en C',
      category: TutorialCategory.codeGeneration,
      estimatedMinutes: 4,
      steps: [
        TutorialStep(
          title: '¿Cómo se Genera el Código?',
          description:
              'La aplicación traduce automáticamente tu diagrama de flujo a código en lenguaje C funcional.',
          keyPoints: [
            'Traducción automática',
            'Código funcional',
            'Listo para compilar',
          ],
        ),
        TutorialStep(
          title: 'Del Diagrama al Código',
          description:
              'Cada nodo se convierte en código C:\n\n• Proceso → Asignación o cálculo\n• Decisión → if/else\n• Entrada → scanf()\n• Salida → printf()\n• Bucle → for/while',
          keyPoints: [
            'Traducción directa',
            'Estructura preservada',
            'Sintaxis correcta',
          ],
          example: 'Diagrama: "Leer edad"\nCódigo: scanf("%d", &edad);',
        ),
        TutorialStep(
          title: 'Compara Diagrama vs Código',
          description:
              'Aprende a relacionar:\n\n• Símbolos → Estructuras de control\n• Conexiones → Flujo de ejecución\n• Decisiones → Condicionales\n• Bucles → Ciclos repetitivos',
          keyPoints: [
            'Relación uno a uno',
            'Misma lógica',
            'Diferente representación',
          ],
        ),
      ],
    );
  }
}
