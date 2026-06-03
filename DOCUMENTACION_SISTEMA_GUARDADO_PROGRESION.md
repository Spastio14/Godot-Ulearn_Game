# Sistema de guardado, progresion y rendimiento para juegos Godot

Este documento describe como replicar el sistema usado en este proyecto para guardar progreso, avanzar niveles, medir rendimiento y mostrar resultados finales. Esta pensado como una guia para entregar a Codex en un repositorio nuevo y pedirle que implemente un sistema equivalente en otro juego hecho con Godot 4.x.

## Archivos clave del proyecto original

- `Scripts/GameManager.gd`: singleton central. Guarda/carga progreso, detecta niveles por escena, mide tiempo, errores, intentos, reinicios, eficiencia, puntajes, fases y resultado global.
- `project.godot`: registra `GameManager` como Autoload, por eso cualquier script puede llamar `GameManager.completar_nivel()`, `GameManager.registrar_fallo_validacion()`, etc.
- `Meu_UI/Menu_UI.gd`: al abrir el menu carga el progreso y decide si continuar desde el nivel guardado o mostrar resultados finales.
- `Meu_UI/FinalResults.gd`: lee el resumen desde `GameManager` y construye tablas de jugador, fases, niveles y resultado global.
- Scripts de nivel: solo notifican eventos al `GameManager`; no escriben archivos directamente.

## Idea central

El sistema separa el juego en dos responsabilidades:

1. Los niveles detectan eventos de gameplay: victoria, validacion fallida, accion incorrecta, reinicio, pista usada.
2. `GameManager` convierte esos eventos en datos persistentes: progreso actual, metricas por nivel, resumen por fase y resultado global.

En un proyecto nuevo, Codex debe implementar primero el `GameManager` como Autoload y despues adaptar cada nivel para reportar eventos mediante su API publica.

## Configuracion minima en Godot

Crear un script `res://Scripts/GameManager.gd` que extienda `Node`.

Registrarlo en `project.godot` o desde Project Settings > Autoload:

```ini
[autoload]
GameManager="*res://Scripts/GameManager.gd"
```

El menu principal debe ser la escena inicial o debe existir una escena inicial que termine llevando al menu. El menu llama `GameManager.cargar_progreso()` en `_ready()`.

## Estructura del catalogo de niveles

El `GameManager` mantiene un diccionario `niveles_config`. Cada entrada representa un nivel jugable.

Campos recomendados:

```gdscript
var niveles_config: Dictionary = {
	1: {
		"id": "nivel_1",
		"nombre": "Nombre visible del nivel",
		"fase": 1,
		"ruta": "res://Niveles/nivel_1.tscn",
		"tiempo_objetivo": 45.0
	},
	2: {
		"id": "nivel_2",
		"nombre": "Segundo nivel",
		"fase": 1,
		"ruta": "res://Niveles/nivel_2.tscn",
		"tiempo_objetivo": 60.0,
		"rutas_adicionales": ["res://Niveles/nivel_2_alt.tscn"]
	}
}
```

Reglas:

- La clave numerica define el orden de progresion.
- `ruta` debe coincidir exactamente con `current_scene.scene_file_path`.
- `fase` permite agrupar niveles por mundos, capitulos o unidades.
- `tiempo_objetivo` se usa para calcular eficiencia.
- `rutas_adicionales` es opcional y sirve cuando dos escenas representan el mismo nivel.

## Modelo de datos persistente

El progreso se guarda como JSON en:

```gdscript
const RUTA_GUARDADO_LOCAL := "user://progreso_rendimiento.json"
```

`user://` es la carpeta de datos de usuario de Godot. Es persistente entre ejecuciones y no forma parte del repo.

Estructura recomendada:

```json
{
	"usuario": "Nombre del jugador",
	"fase_actual": 1,
	"nivel_actual": 1,
	"niveles": {
		"1": {
			"numero_nivel": 1,
			"nivel_id": "nivel_1",
			"nombre_nivel": "Nombre visible",
			"fase": 1,
			"inicio_unix": 1770000000.0,
			"fin_unix": 1770000040.0,
			"duracion": 40.0,
			"intentos_fallidos": 0,
			"acciones_incorrectas": 0,
			"reinicios": 0,
			"fallos_validacion": 0,
			"pistas_usadas": 0,
			"errores": 0,
			"completado": true,
			"porcentaje": 100.0,
			"eficiencia": 100.0,
			"tasa_exito": 100.0,
			"puntaje_general": 100.0,
			"clasificacion": "Ejecucion perfecta"
		}
	},
	"fases": {},
	"global": {}
}
```

## Flujo de vida del sistema

### 1. Arranque

En `_ready()` del `GameManager`:

- Llama `cargar_guardado_local()`.
- Conecta `get_tree().node_added` para detectar cambios de escena.

En `_process()`:

- Lee `get_tree().current_scene.scene_file_path`.
- Si la ruta cambio, busca el nivel correspondiente en `niveles_config`.
- Si encuentra un nivel, llama `start_level_tracking(numero_nivel)`.

Esto permite que el seguimiento empiece automaticamente al entrar a una escena registrada.

### 2. Inicio de seguimiento

`start_level_tracking(numero_nivel)` inicializa `metricas_nivel_actual` con:

- Numero, id, nombre y fase del nivel.
- `inicio_unix` con `Time.get_unix_time_from_system()`.
- Contadores en cero: errores, intentos, reinicios, fallos, pistas.
- Valores de resultado en cero.
- `seguimiento_activo = true`.

Tambien emite:

```gdscript
signal seguimiento_nivel_iniciado(datos_nivel: Dictionary)
```

### 3. Eventos durante el nivel

Los niveles deben llamar al `GameManager` cuando ocurra algo medible:

```gdscript
GameManager.registrar_fallo_validacion()
GameManager.registrar_accion_incorrecta()
GameManager.registrar_reinicio()
GameManager.registrar_pista_usada()
GameManager.register_retry()
GameManager.register_error(1, "validacion")
```

Eventos usados en el proyecto original:

- Base de datos: si el jugador presiona validar y la respuesta esta mal, se llama `registrar_fallo_validacion()`.
- Redes: si se rechaza una conexion no permitida, se llama `registrar_accion_incorrecta()`.
- Redes: si el jugador reinicia la escena, se llama `registrar_reinicio()` y luego `reload_current_scene()`.
- Robot y circuitos: al detectar victoria, llaman `completar_nivel()`.

### 4. Finalizacion del nivel

Cuando el jugador gana:

```gdscript
GameManager.completar_nivel()
```

O, si se quiere cambiar automaticamente a una ruta concreta:

```gdscript
GameManager.completar_nivel("res://Niveles/nivel_2.tscn")
```

Internamente `completar_nivel()` llama `finish_level_tracking(true)`, que:

- Calcula `fin_unix`.
- Calcula `duracion`.
- Marca `completado = true`.
- Calcula puntaje del nivel.
- Guarda el resultado en `datos_rendimiento["niveles"][numero]`.
- Si fue completado, avanza `nivel_actual` al siguiente.
- Actualiza `fase_actual`.
- Recalcula resumen global.
- Guarda localmente y, si existe backend, remotamente.
- Emite `seguimiento_nivel_finalizado` y `estadisticas_actualizadas`.

## Formulas de puntuacion

Constantes originales:

```gdscript
const PUNTAJE_MAXIMO := 100.0
const PENALIZACION_ERROR := 6.0
const PENALIZACION_INTENTO := 8.0
const PENALIZACION_REINICIO := 10.0
const PENALIZACION_VALIDACION := 5.0
const PENALIZACION_PISTA := 2.0
const PENALIZACION_ACCION_INCORRECTA := 4.0
```

Eficiencia:

```gdscript
eficiencia = tiempo_objetivo / max(tiempo_objetivo, duracion)
```

Si el jugador termina antes o justo en el tiempo objetivo, eficiencia = 1.0. Si tarda mas, baja proporcionalmente.

Penalizacion por tiempo:

```gdscript
penalizacion_tiempo = (1.0 - eficiencia) * 25.0
```

Penalizacion por errores:

```gdscript
penalizacion_errores = errores * 6
penalizacion_errores += acciones_incorrectas * 4
penalizacion_errores += fallos_validacion * 5
penalizacion_errores += pistas_usadas * 2
```

Penalizacion por intentos:

```gdscript
penalizacion_reintentos = intentos_fallidos * 8
penalizacion_reintentos += reinicios * 10
```

Puntaje final del nivel:

```gdscript
puntaje = clamp(100 - penalizacion_tiempo - penalizacion_errores - penalizacion_reintentos, 0, 100)
```

Tasa de exito:

```gdscript
total_intentos = max(1, intentos_fallidos + 1)
tasa_exito = 1.0 / total_intentos
```

Clasificacion por porcentaje:

- 95 a 100: `Ejecucion perfecta`
- 90 a 94.99: `Errores menores`
- 80 a 89.99: `Rendimiento aceptable`
- 70 a 79.99: `Multiples errores`
- 60 a 69.99: `Errores excesivos`
- Menos de 60: `Rendimiento bajo`

## Resumen por fase

`calculate_phase_score(numero_fase)` debe:

- Buscar todos los resultados de niveles cuya `fase` coincida.
- Contar niveles completados.
- Contar niveles totales de esa fase desde `niveles_config`.
- Sumar puntajes, errores y duracion.
- Calcular promedio de puntaje.
- Calcular porcentaje completado.

Salida esperada:

```gdscript
{
	"fase": numero_fase,
	"niveles_completados": completados,
	"niveles_totales": total_niveles_fase,
	"puntaje_promedio": promedio,
	"errores_totales": total_errores,
	"tiempo_total": total_tiempo,
	"porcentaje_completado": completion
}
```

## Resumen global

`calculate_global_score()` debe:

- Tomar todos los niveles guardados.
- Calcular tiempo total, errores totales, intentos totales y niveles completados.
- Calcular promedio de puntajes por nivel.
- Recalcular cada fase y guardarla en `datos_rendimiento["fases"]`.
- Calcular cuantas fases estan completadas al 100%.
- Calcular porcentaje final con ponderacion:

```gdscript
porcentaje_final = promedio_niveles * 0.7 + promedio_fases * 0.3
```

Salida global:

```gdscript
{
	"tiempo_total": 0.0,
	"errores_totales": 0,
	"intentos_totales": 0,
	"niveles_completados": 0,
	"niveles_totales": obtener_total_niveles(),
	"fases_completadas": 0,
	"fases_totales": 0,
	"puntaje_promedio_niveles": 0.0,
	"puntaje_promedio_fases": 0.0,
	"porcentaje_final": 0.0,
	"rango_final": "Necesita mejorar"
}
```

Rangos finales:

- 95 a 100: `Experto`
- 85 a 94.99: `Avanzado`
- 70 a 84.99: `Intermedio`
- 60 a 69.99: `Principiante`
- Menos de 60: `Necesita mejorar`

## Guardado local

Implementacion requerida:

```gdscript
func guardar_progreso() -> void:
	datos_rendimiento["usuario"] = usuario
	datos_rendimiento["fase_actual"] = fase_actual
	datos_rendimiento["nivel_actual"] = nivel_actual
	_guardar_archivo_local()
	_guardar_progreso_remoto()

func _guardar_archivo_local() -> void:
	var archivo := FileAccess.open(RUTA_GUARDADO_LOCAL, FileAccess.WRITE)
	if archivo == null:
		push_warning("No se pudo abrir el archivo de guardado local.")
		return
	archivo.store_string(JSON.stringify(datos_rendimiento, "\t"))
```

Para un juego nuevo sin backend, `_guardar_progreso_remoto()` puede quedar vacio o eliminarse.

## Carga local y fusion de datos

El sistema original permite cargar datos locales y tambien fusionar datos remotos. La funcion importante es `_fusionar_guardado(datos)`.

Debe aceptar:

- `usuario`
- `nivel_actual`
- `nivel` como alias antiguo de `nivel_actual`
- `fase_actual`
- `rendimiento` como contenedor anidado
- `niveles`
- `fases`
- `global`

Despues de fusionar debe recalcular el global.

Pseudoflujo:

```gdscript
func cargar_guardado_local() -> void:
	if not FileAccess.file_exists(RUTA_GUARDADO_LOCAL):
		return
	var archivo := FileAccess.open(RUTA_GUARDADO_LOCAL, FileAccess.READ)
	if archivo == null:
		return
	var datos = JSON.parse_string(archivo.get_as_text())
	if datos is Dictionary:
		_fusionar_guardado(datos)
```

## Guardado remoto opcional

El proyecto original envia un POST JSON a:

```text
{servidor}/guardar_progreso.php
```

Cuerpo:

```json
{
	"usuario": "Nombre",
	"carrera_id": "computacion",
	"nivel_actual": 3,
	"fase_actual": 1,
	"rendimiento": {}
}
```

Tambien intenta cargar progreso remoto con:

```text
{servidor}/obtener_progreso.php?usuario={usuario}
```

Para un juego nuevo, Codex debe hacerlo configurable. Si no se proporciona backend, el sistema debe funcionar solo con JSON local.

## Menu principal

El menu no necesita saber detalles de puntajes. Solo debe:

1. Llamar `GameManager.cargar_progreso()` al iniciar.
2. Al presionar jugar, leer `GameManager.nivel_actual`.
3. Si `nivel_actual` supera el total, abrir resultados finales.
4. Si existe una ruta para ese nivel, cambiar a esa escena.
5. Si no existe ruta, abrir resultados finales.

Ejemplo:

```gdscript
extends Control

func _ready() -> void:
	GameManager.cargar_progreso()

func empezar_juego() -> void:
	var total_niveles := GameManager.obtener_total_niveles()
	if GameManager.nivel_actual > total_niveles:
		GameManager.mostrar_resultados_finales()
		return
	var nivel := int(clamp(GameManager.nivel_actual, 1, total_niveles))
	var ruta := GameManager.obtener_ruta_nivel(nivel)
	if ruta.is_empty():
		GameManager.mostrar_resultados_finales()
		return
	get_tree().change_scene_to_file(ruta)
```

## Pantalla de resultados finales

Debe llamar:

```gdscript
var resultados: Dictionary = GameManager.obtener_resumen_resultados()
```

Y mostrar:

- Nombre del jugador.
- Tiempo total con `GameManager.formatear_tiempo(segundos)`.
- Errores totales.
- Intentos totales.
- Niveles completados / totales.
- Fases completadas / totales.
- Tabla de fases.
- Tabla de niveles.
- Promedio de niveles.
- Promedio de fases.
- Porcentaje final.
- Rango final.

La pantalla original construye las filas dinamicamente con `Label.new()` dentro de `GridContainer`. En otro proyecto se puede usar la misma idea o una UI ya disenada, siempre que consuma el mismo diccionario.

## Contrato para scripts de nivel

Cada nivel nuevo debe seguir este contrato:

### Al iniciar

No es obligatorio llamar manualmente `start_level_tracking()` si la escena esta registrada en `niveles_config`, porque el `GameManager` detecta la escena. Si el juego usa escenas dinamicas o subniveles no registrados, llamar:

```gdscript
GameManager.start_level_tracking(numero_nivel)
```

### Al ganar

```gdscript
await get_tree().create_timer(0.5).timeout
GameManager.completar_nivel()
get_tree().change_scene_to_file("res://Niveles/siguiente.tscn")
```

O:

```gdscript
GameManager.completar_nivel("res://Niveles/siguiente.tscn")
```

### Al fallar una validacion

```gdscript
GameManager.registrar_fallo_validacion()
```

### Al hacer una accion incorrecta

```gdscript
GameManager.registrar_accion_incorrecta()
```

### Al reiniciar

```gdscript
GameManager.registrar_reinicio()
get_tree().reload_current_scene()
```

### Al usar pista

```gdscript
GameManager.registrar_pista_usada()
```

## API publica que Codex debe implementar

Funciones de progresion:

- `obtener_nivel_por_ruta(ruta: String) -> int`
- `obtener_ruta_nivel(numero_nivel: int) -> String`
- `obtener_siguiente_ruta_nivel(numero_nivel: int) -> String`
- `obtener_total_niveles() -> int`
- `completar_nivel(ruta_siguiente: String = "") -> Dictionary`
- `completar_nivel_y_cambiar(ruta_siguiente: String) -> void`
- `mostrar_resultados_finales() -> void`

Funciones de seguimiento:

- `start_level_tracking(numero_nivel: int = nivel_actual) -> void`
- `finish_level_tracking(completado: bool = true) -> Dictionary`
- `register_error(cantidad: int = 1, tipo: String = "error") -> void`
- `register_retry(cantidad: int = 1) -> void`
- `registrar_reinicio(cantidad: int = 1) -> void`
- `registrar_fallo_validacion(cantidad: int = 1) -> void`
- `registrar_accion_incorrecta(cantidad: int = 1) -> void`
- `registrar_pista_usada(cantidad: int = 1) -> void`

Funciones de calculo:

- `calculate_level_score(metricas: Dictionary) -> Dictionary`
- `calculate_phase_score(numero_fase: int) -> Dictionary`
- `calculate_global_score() -> Dictionary`
- `obtener_clasificacion_porcentaje(porcentaje: float) -> String`
- `obtener_rango_final(porcentaje: float) -> String`
- `formatear_tiempo(segundos: float) -> String`

Funciones de persistencia:

- `guardar_progreso() -> void`
- `cargar_progreso() -> void`
- `cargar_guardado_local() -> void`
- `obtener_resumen_resultados() -> Dictionary`

Senales:

```gdscript
signal seguimiento_nivel_iniciado(datos_nivel: Dictionary)
signal seguimiento_nivel_finalizado(resultado_nivel: Dictionary)
signal estadisticas_actualizadas(resumen_global: Dictionary)
```

## Instrucciones concretas para Codex en un repo nuevo

Usar este bloque como prompt base:

```text
Implementa en este proyecto Godot 4.x un sistema de guardado, progresion y rendimiento basado en el documento DOCUMENTACION_SISTEMA_GUARDADO_PROGRESION.md.

Requisitos:
1. Crear `res://Scripts/GameManager.gd` como singleton Autoload llamado `GameManager`.
2. Configurar un catalogo `niveles_config` con los niveles reales del nuevo juego: id, nombre, fase, ruta y tiempo_objetivo.
3. Guardar el progreso local en `user://progreso_rendimiento.json` como JSON.
4. Cargar progreso desde el menu principal y continuar desde `nivel_actual`.
5. Detectar automaticamente la escena actual y empezar tracking si la ruta coincide con un nivel registrado.
6. Exponer la API publica indicada en el documento.
7. Adaptar cada nivel para llamar `GameManager.completar_nivel()` al ganar.
8. Adaptar validaciones, errores, reinicios y pistas para llamar las funciones de registro correspondientes.
9. Crear o adaptar una pantalla de resultados finales que consuma `GameManager.obtener_resumen_resultados()`.
10. El backend remoto es opcional; si no existe servidor, dejarlo desactivado sin romper guardado local.

Mantener el sistema desacoplado: los niveles reportan eventos, pero nunca escriben archivos directamente.
```

## Checklist de implementacion

- `GameManager.gd` existe y extiende `Node`.
- `GameManager` esta registrado como Autoload.
- `niveles_config` contiene todas las escenas jugables.
- El menu llama `GameManager.cargar_progreso()`.
- El boton jugar usa `GameManager.nivel_actual` y `GameManager.obtener_ruta_nivel()`.
- Cada escena de nivel esta en el catalogo con su ruta exacta.
- Cada victoria llama `GameManager.completar_nivel()`.
- Cada fallo de validacion llama `GameManager.registrar_fallo_validacion()`.
- Cada accion invalida llama `GameManager.registrar_accion_incorrecta()`.
- Cada reinicio llama `GameManager.registrar_reinicio()`.
- El JSON se crea en `user://progreso_rendimiento.json`.
- La pantalla final usa `GameManager.obtener_resumen_resultados()`.
- Al completar el ultimo nivel se llama `GameManager.mostrar_resultados_finales()`.

## Riesgos y mejoras recomendadas

- En el proyecto original algunas escenas cambian manualmente al siguiente nivel y otras usan `obtener_siguiente_ruta_nivel()`. En un juego nuevo conviene elegir una sola estrategia, preferiblemente usar el catalogo central.
- El guardado remoto esta acoplado a PHP y a una URL fija. Conviene convertirlo en opcion configurable o desactivarlo por defecto.
- El nombre de usuario esta fijo en el script original. En un juego nuevo debe venir de una pantalla de perfil, entrada de texto o servicio de cuenta.
- Si se llama muchas veces `registrar_fallo_validacion()` en validaciones automaticas, el puntaje puede bajar demasiado rapido. Para juegos con validacion continua, registrar el fallo solo cuando el jugador presiona un boton o confirma una accion.
- Al reiniciar una escena, `registrar_reinicio()` tambien suma un intento fallido porque llama `register_retry()`. Mantenerlo asi si un reinicio debe penalizar doble: intento + reinicio.
- Para borrar progreso durante pruebas, crear una funcion de debug que elimine `user://progreso_rendimiento.json`, pero no incluirla como boton visible en produccion.

