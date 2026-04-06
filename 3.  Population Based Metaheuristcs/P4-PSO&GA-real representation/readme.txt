===========================================================================
PRACTICAL ASSIGNMENT: Experimental Comparison of PSO and GA
Sistemas Inteligentes - Universidad de Cádiz
Autor: José Álvaro García Márquez
===========================================================================

1. DESCRIPCIÓN GENERAL
---------------------------------------------------------------------------
Este repositorio contiene la implementación en MATLAB de dos metaheurísticas 
(Particle Swarm Optimization y un Algoritmo Genético de codificación real) 
para la optimización de funciones continuas (Ackley y Rastrigin). 

Cumpliendo con los requisitos de la práctica, TODO el código ha sido 
estrictamente vectorizado ("evaluate populations in batch" y "avoid 
unnecessary loops") para maximizar la eficiencia computacional.

2. ESTRUCTURA DE ARCHIVOS
---------------------------------------------------------------------------
Scripts principales de ejecución:
- main_experimentos.m   : Script maestro. Ejecuta el protocolo experimental
                          completo (100 runs x 2 algoritmos x 2 dimensiones 
                          x 2 funciones). Imprime las estadísticas por 
                          consola y genera las figuras comparativas.

- visualization.m : 	  Script correspondiente a la Tarea 2.1. Genera 
                          los gráficos 3D (surf) y de contorno (contour) 
                          de las funciones de Ackley y Rastrigin.


Algoritmos (Metaheurísticas):
- run_pso.m             : Implementación del PSO. Incluye control de 
                          límites (bound handling), límite de velocidad 
                          (velocity clamping) e inercia adaptativa decreciente.

- run_ga.m              : Implementación del GA Real. Incluye selección por 
                          torneo, Cruce Aritmético, Mutación Gaussiana 
                          decreciente y Elitismo estricto.


Funciones objetivo (Vectorizadas):
- eval_ackley.m         : Función de Ackley preparada para recibir matrices [NxD].
- eval_rastrigin.m      : Función de Rastrigin preparada para matrices [NxD].

3. INSTRUCCIONES DE EJECUCIÓN
---------------------------------------------------------------------------
1. Extraer todos los archivos del .zip en una única carpeta.
2. Abrir MATLAB y establecer dicha carpeta como el "Current Folder" (Directorio de trabajo).
3. Para ver el comportamiento y análisis comparativo (Task 2.4, 2.5 y 2.6):
   >> run main_experimentos.m
4. Para ver la visualización de los "Landscapes" (Task 2.1):
   >> run visualization.m

4. NOTA SOBRE EL RENDIMIENTO (OUTPUT ESPERADO)
---------------------------------------------------------------------------
Al ejecutar 'main_experimentos.m', el script realizará 800 ejecuciones 
independientes (500 iteraciones y 50 individuos por ejecución). Gracias a 
la vectorización mediante álgebra matricial en MATLAB, el tiempo total de 
procesamiento de todo el experimento es de apenas unos segundos. 

Al finalizar, se mostrará en la Command Window el porcentaje de éxito 
(f(x) < 1e-3), la media final y la desviación estándar, y se abrirán dos 
ventanas con las curvas de convergencia (semilogy) y los boxplots de robustez.
===========================================================================