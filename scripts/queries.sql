USE sistema_transporte;                              


/* --------- 12) Promedio de calificaciones por chofer --------- */
SELECT uvt.usuario_chofer_id as id_chofer,            -- Muestra el ID del chofer (columna de uvt).
       CONCAT(u.nombre, ' ',u.apellido) nombre_completo, -- Nombre y apellido del chofer.
       AVG(calif.puntuacion) puntuacion_promedio      -- Promedio de la puntuación de sus viajes.
FROM usuarios_viajes_tarjetas uvt                     
LEFT JOIN calificaciones calif                        -- LEFT JOIN para no perder choferes sin calificación.
  ON uvt.viaje_id = calif.viaje_id                    -- Relaciona calificaciones por el viaje.
LEFT JOIN usuarios AS u                               -- Trae datos del chofer.
  ON uvt.usuario_chofer_id = u.usuario_id             -- Une el chofer (usuario) con uvt.
GROUP BY uvt.usuario_chofer_id,                       -- Agrupa por chofer para calcular AVG por chofer.
         CONCAT(u.nombre, ' ',u.apellido)             -- También agrupa por el nombre completo mostrado.
ORDER BY AVG(calif.puntuacion) DESC;                  -- Ordena de mayor a menor promedio.

/* --------- 13) Historial de viajes de un pasajero --------- */
SELECT v.viaje_id, v.origen, v.destino, v.costo, v.estado            -- Columnas informativas del viaje.
FROM usuarios_viajes_tarjetas uvt                                   
JOIN viajes v ON uvt.viaje_id = v.viaje_id                           -- Une para recuperar los datos del viaje.
WHERE uvt.usuario_pasajero_id = 1;                                   -- Filtra por el pasajero (ID 1).

/* --------------- 14) Chofer asignado a un viaje --------------- */
SELECT u.nombre, u.apellido, u.email, u.telefono       -- Datos de contacto del chofer.
FROM usuarios_viajes_tarjetas uvt                      -- Tabla puente.
JOIN usuarios u ON u.usuario_id = uvt.usuario_chofer_id-- Une el chofer (usuario) asignado a ese viaje.
WHERE uvt.viaje_id = 1;                                -- Para el viaje con ID = 1.

/* --------------- 15) Vehículos con seguros vigentes --------------- */
SELECT v.marca, v.modelo, v.patente,                   -- Datos del vehículo.
       s.compania, s.fecha_vencimiento                 -- Aseguradora y vencimiento.
FROM vehiculos v                                       -- Tabla de vehículos.
JOIN seguros s ON v.vehiculo_id = s.vehiculo_id        -- Une su seguro correspondiente.
WHERE s.fecha_vencimiento >= GETDATE();                -- Solo seguros vigentes a hoy.

/* --------------- 16) Total gastado por pasajero --------------- */
SELECT u.usuario_id,                                   -- ID del pasajero.
       CONCAT(u.nombre, ' ',u.apellido) nombre_completo, -- Nombre del pasajero.
       SUM(v.costo) AS total_gastado                   -- Suma de costos de viajes finalizados.
FROM usuarios u                                        -- Tabla de usuarios (pasajeros).
JOIN usuarios_viajes_tarjetas uvt                      -- Une con la relación viaje-tarjeta.
  ON u.usuario_id = uvt.usuario_pasajero_id            -- Filtra relación por pasajero.
JOIN viajes v                                          -- Trae los costos/estados del viaje.
  ON uvt.viaje_id = v.viaje_id
WHERE v.estado = 'finalizado'                          -- Solo viajes ya finalizados.
GROUP BY u.usuario_id,                                 -- Agrupa por pasajero para sumar.
         CONCAT(u.nombre, ' ',u.apellido)
ORDER BY total_gastado DESC;                           -- Ordena de mayor a menor gasto.

/* 20) Reporte de viajes (chofer, pasajero, vehículo, costo, estado) */
SELECT 
  v.viaje_id,                                          -- Identificador del viaje.
  v.origen,                                            -- Origen.
  v.destino,                                           -- Destino.
  chofer.nombre + ' ' + chofer.apellido AS chofer,     -- Nombre completo del chofer.
  pasajero.nombre + ' ' + pasajero.apellido AS pasajero,-- Nombre completo del pasajero.
  v.costo,                                             -- Costo del viaje.
  v.estado,                                            -- Estado ('pendiente', 'en curso', etc.).
  vh.patente                                           -- Patente del vehículo utilizado.
FROM usuarios_viajes_tarjetas uvt                      -- Tabla puente que enlaza todo.
JOIN viajes v ON uvt.viaje_id = v.viaje_id             -- Une viajes para datos generales.
JOIN usuarios chofer ON uvt.usuario_chofer_id = chofer.usuario_id   -- Datos del chofer.
JOIN usuarios pasajero ON uvt.usuario_pasajero_id = pasajero.usuario_id -- Datos del pasajero.
JOIN vehiculos vh ON v.vehiculo_id = vh.vehiculo_id;   -- Datos del vehículo.
