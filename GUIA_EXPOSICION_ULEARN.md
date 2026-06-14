# Guía de Exposición: Proyecto Ulearn
### *Cómo presentar el proyecto de manera profesional, técnica y sencilla*

Esta guía está diseñada para ayudarte a exponer el proyecto **Ulearn** ante un jurado, docentes o compañeros. El lenguaje propuesto es formal y técnico para demostrar conocimiento, pero utiliza analogías sencillas para que no te enredes al hablar y puedas responder cualquier pregunta con total naturalidad.

---

## Estructura de la Presentación (Paso a Paso)

### 1. Introducción y Propósito del Proyecto (El "Qué" y "Por qué")
*   **Qué decir:**
    > *"Buenos días/tardes. Hoy les presentaré **Ulearn**, una plataforma educativa interactiva desarrollada en el motor Godot Engine. El objetivo principal de este proyecto es transformar la enseñanza de conceptos complejos en Ingeniería de Computación —como programación, circuitos, bases de datos y redes— en desafíos prácticos y gamificados. En lugar de limitarse a leer teoría, el usuario aprende experimentando y resolviendo problemas en tiempo real."*
*   **Término técnico explicado de forma sencilla:**
    *   *Gamificación:* Es simplemente aplicar mecánicas de juego (puntos, niveles, medallas) en entornos que no son juegos (como la educación) para motivar al usuario.

---

### 2. Arquitectura de Software (El "Cómo funciona por detrás")
*   **Qué decir:**
    > *"Para el desarrollo del juego, optamos por una arquitectura desacoplada. Esto significa que separamos el gameplay de cada nivel del sistema que procesa las métricas y los archivos de guardado. El núcleo de esto es nuestro **GameManager**, un componente global que actúa como un 'observador silencioso'. Este GameManager detecta en qué nivel está el jugador, inicia un temporizador y registra cada acción: si se equivoca, si pide una pista o si reinicia el nivel. Al finalizar, calcula la puntuación y la guarda en un archivo de formato JSON local, y si hay conexión, la sincroniza automáticamente con un servidor web remoto."*
*   **Términos técnicos explicados de forma sencilla:**
    *   *Desacoplado:* Es como un carro y su radio. Si cambias la radio, el motor del carro sigue funcionando igual. En nuestro juego, si cambiamos las reglas de un nivel, el sistema de guardado no se rompe porque son independientes.
    *   *Autoload / Singleton:* Es un script que siempre está encendido y disponible en la memoria del juego de principio a fin, sin importar en qué nivel o menú estemos.
    *   *Formato JSON:* Es una forma muy limpia y ligera de escribir datos en un archivo de texto estructurado para que la computadora lo lea rápidamente (como una lista de compras organizada).

---

### 3. Las Cuatro Fases de Aprendizaje (El Gameplay)
*   **Qué decir:**
    > *"El juego está dividido en cuatro fases progresivas, cada una enfocada en un área clave de la computación:*
    >
    > 1. * **Fase de Programación:** Aquí el usuario controla un robot. El objetivo es diseñar una secuencia ordenada de pasos para superar obstáculos y abrir puertas. Enseña **lógica algorítmica** y cómo piensa una computadora paso a paso.
    > 2. * **Fase de Circuitos:** El jugador interconecta compuertas lógicas como AND, OR y NOT para energizar computadoras. Enseña cómo viaja la electricidad y cómo funciona la **lógica booleana** en el procesador de cualquier dispositivo.
    > 3. * **Fase de Bases de Datos:** Aquí se trabaja organizando tablas y asociando datos mediante llaves relacionales. Enseña la importancia del **orden e integridad de la información**, que es la base de cualquier sistema moderno como Facebook o los bancos.
    > 4. * **Fase de Redes:** El jugador conecta computadoras, routers y servidores. Debe optimizar las conexiones para transferir datos rápidamente sin saturar los puertos de red. Enseña **infraestructura de redes, enrutamiento de paquetes e Internet**."*

---

### 4. Telemetría y Sistema de Evaluación (Las Métricas)
*   **Qué decir:**
    > *"Uno de los puntos fuertes de Ulearn es su sistema de evaluación. No evaluamos con un simple 'aprobado o reprobado'. Evaluamos la **eficiencia**. Cada nivel tiene un 'tiempo objetivo' sugerido. Si el jugador lo resuelve rápido y sin errores, obtiene un puntaje perfecto de 100. Pero si tarda más tiempo, comete errores de conexión, solicita pistas o reinicia la pantalla, el sistema aplica penalizaciones matemáticas proporcionales. Al final, el juego pondera el desempeño global del jugador en un rango de aprendizaje que va desde 'Principiante' hasta 'Experto'."*
*   **Términos técnicos explicados de forma sencilla:**
    *   *Telemetría:* Es simplemente medir y recopilar datos a distancia sobre el comportamiento de algo (en este caso, cómo juega y aprende el usuario).

---

### 5. Conclusión y Futuras Mejoras
*   **Qué decir:**
    > *"En resumen, Ulearn demuestra cómo los videojuegos pueden ser herramientas potentes de aprendizaje interactivo. Como líneas de trabajo futuro, el sistema está preparado para integrar APIs de análisis de datos que permitan a los profesores ver gráficos de qué temas les cuestan más trabajo a sus estudiantes, facilitando una retroalimentación personalizada. Muchas gracias, quedo atento a sus preguntas."*

---

## Acordeón de Respuestas Rápidas (Para la sección de preguntas)

1.  **¿Por qué usaron Godot 4 en lugar de Unity o Unreal?**
    *   *Respuesta técnica/sencilla:* Godot 4 es de código abierto, sumamente ligero y su lenguaje de programación (GDScript) es muy parecido a Python, lo que agiliza el desarrollo de juegos en 2D y 3D sin el consumo excesivo de recursos de otros motores.
2.  **¿Qué pasa si el servidor web se cae? ¿El juego deja de funcionar?**
    *   *Respuesta técnica/sencilla:* No, el juego tiene tolerancia a fallos. Si el servidor remoto no responde, el `GameManager` atrapa el error y trabaja 100% de manera local con el archivo JSON del usuario. Cuando el servidor vuelva a estar en línea, se puede volver a sincronizar.
3.  **¿Cómo funciona la fórmula de eficiencia del tiempo?**
    *   *Respuesta técnica/sencilla:* Dividimos el tiempo objetivo del nivel entre el tiempo real que tomó el jugador. Si tardó menos del objetivo, la división da 1 (100% eficiente). Si tardó el doble, da 0.5 (50% eficiente) y a partir de ahí se descuentan algunos puntos. Es una forma justa de motivar a resolver el reto con agilidad.
