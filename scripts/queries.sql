USE sistema_transporte;                              


/* --------- 12) Promedio de calificaciones por chofer --------- */
SELECT uvt.usuario_chofer_id as id_chofer,
       CONCAT(u.nombre, ' ',u.apellido) nombre_completo,
       AVG(calif.puntuacion) puntuacion_promedio
FROM usuarios_viajes_tarjetas uvt                     
LEFT JOIN calificaciones calif
  ON uvt.viaje_id = calif.viaje_id
LEFT JOIN usuarios AS u
  ON uvt.usuario_chofer_id = u.usuario_id
GROUP BY uvt.usuario_chofer_id,
         CONCAT(u.nombre, ' ',u.apellido)
ORDER BY AVG(calif.puntuacion) DESC;

/* --------- 13) Historial de viajes de un pasajero --------- */
SELECT v.viaje_id, v.origen, v.destino, v.costo, v.estado
FROM usuarios_viajes_tarjetas uvt                                   
JOIN viajes v ON uvt.viaje_id = v.viaje_id
WHERE uvt.usuario_pasajero_id = 1;

/* --------------- 14) Chofer asignado a un viaje --------------- */
SELECT u.nombre, u.apellido, u.email, u.telefono
FROM usuarios_viajes_tarjetas uvt
JOIN usuarios u ON u.usuario_id = uvt.usuario_chofer_id
WHERE uvt.viaje_id = 1;

/* --------------- 15) Vehículos con seguros vigentes --------------- */
SELECT v.marca, v.modelo, v.patente,
       s.compania, s.fecha_vencimiento
FROM vehiculos v
JOIN seguros s ON v.vehiculo_id = s.vehiculo_id
WHERE s.fecha_vencimiento >= GETDATE();

/* --------------- 16) Total gastado por pasajero --------------- */
SELECT u.usuario_id,
       CONCAT(u.nombre, ' ',u.apellido) nombre_completo,
       SUM(v.costo) AS total_gastado
FROM usuarios u
JOIN usuarios_viajes_tarjetas uvt
  ON u.usuario_id = uvt.usuario_pasajero_id
JOIN viajes v
  ON uvt.viaje_id = v.viaje_id
WHERE v.estado = 'finalizado'
GROUP BY u.usuario_id,
         CONCAT(u.nombre, ' ',u.apellido)
ORDER BY total_gastado DESC;

/* 20) Reporte de viajes (chofer, pasajero, vehículo, costo, estado) */
SELECT 
  v.viaje_id,
  v.origen,
  v.destino,
  chofer.nombre + ' ' + chofer.apellido AS chofer,
  pasajero.nombre + ' ' + pasajero.apellido AS pasajero,
  v.costo,
  v.estado,
  vh.patente
FROM usuarios_viajes_tarjetas uvt
JOIN viajes v ON uvt.viaje_id = v.viaje_id
JOIN usuarios chofer ON uvt.usuario_chofer_id = chofer.usuario_id
JOIN usuarios pasajero ON uvt.usuario_pasajero_id = pasajero.usuario_id
JOIN vehiculos vh ON v.vehiculo_id = vh.vehiculo_id;
