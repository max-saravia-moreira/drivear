use sistema_transporte;

-- 1. Insertar un usuario pasajero

INSERT INTO usuarios (cuit_cuil, nombre, apellido, email, telefono, calle, altura, codigo_postal, tipo_usuario, estado, contrasena)
VALUES (20345678902, 'Ramon', 'Lucci', 'lucho02@email.com', 2222333344, 'Av. caseros', 111, 2222, 'pasajero', 'activo', 'lucho_pass');

-- 2. Insertar un conductor
INSERT INTO usuarios (cuit_cuil, nombre, apellido, email, telefono, calle, altura, codigo_postal, tipo_usuario, estado, contrasena)
VALUES (27333222119, 'Carlos', 'Gómez', 'carlos.gomez@email.com', 1167788990, 'Calle San Martín', 456, 1638, 'chofer', 'activo', 'hashed_password');

-- 3. Registrar una licencia para el chofer
INSERT INTO licencias (numero_licencia, categoria, fecha_emision, fecha_vencimiento, usuario_id)
VALUES (987654, 'C1', '2024-01-10', '2028-01-10', 2);

-- 4. Registrar un vehículo del chofer
INSERT INTO vehiculos (marca, modelo, color, patente, anio, usuario_id)
VALUES ('Toyota', 'Corolla', 'Blanco', 'ABC123', 2022, 2);

-- 5. Registrar un seguro del vehículo
INSERT INTO seguros (compania, tipo_seguro, numero_poliza, fecha_vencimiento, cobertura_detalle, vehiculo_id)
VALUES ('Sancor Seguros', 'Total', 4455123, '2026-06-01', 'Cobertura completa contra terceros y robo total', 1);

-- 6. Registrar una tarjeta del pasajero
INSERT INTO tarjetas (numero_tarjeta, nombre_titular, tipo_tarjeta, entidad_bancaria, red_pago, cvv, vencimiento, usuario_id)
VALUES (1111222233334444, 'Juan Pérez', 'credito', 'Banco Nación', 'Visa', 123, '2027-08-31', 1);

-- 7. Crear un viaje pendiente
INSERT INTO viajes (fecha, origen, destino, hora_inicial, distancia_km, costo, estado, vehiculo_id)
VALUES ('2025-11-02', 'Buenos Aires', 'La Plata', '08:00', 60.5, 5000, 'pendiente', 1);

-- 8. Asociar pasajero, chofer, viaje y tarjeta
INSERT INTO usuarios_viajes_tarjetas (usuario_chofer_id, usuario_pasajero_id, viaje_id, tarjeta_id)
VALUES (2, 1, 1, 1);

-- 9. Actualizar el estado del viaje a “en curso”
UPDATE viajes
SET estado = 'en curso', actualizado_fecha = GETDATE()
WHERE viaje_id = 1;

-- 10. Finalizar el viaje
UPDATE viajes
SET estado = 'finalizado', hora_final = '09:00', actualizado_fecha = GETDATE()
WHERE viaje_id = 1;

-- 11. Calificar el viaje
INSERT INTO calificaciones (puntuacion, comentario, viaje_id, creado_por)
VALUES (5, 'Excelente servicio, muy puntual.', 1, 1);

-- 12. Promedio de calificaciones por chofer
SELECT u.nombre, u.apellido, AVG(c.puntuacion) AS promedio_calificacion
FROM calificaciones c
JOIN viajes v ON c.viaje_id = v.viaje_id
JOIN vehiculos vh ON v.vehiculo_id = vh.vehiculo_id
JOIN usuarios u ON vh.usuario_id = u.usuario_id
GROUP BY u.nombre, u.apellido;

-- 13. Historial de viajes de un pasajero
SELECT v.viaje_id, v.fecha, v.origen, v.destino, v.costo, v.estado
FROM usuarios_viajes_tarjetas uvt
JOIN viajes v ON uvt.viaje_id = v.viaje_id
WHERE uvt.usuario_pasajero_id = 1;

-- 14. Chofer asignado a un viaje
SELECT u.nombre, u.apellido, u.email, u.telefono
FROM usuarios_viajes_tarjetas uvt
JOIN usuarios u ON u.usuario_id = uvt.usuario_chofer_id
WHERE uvt.viaje_id = 1;

-- 15. Vehículos con seguros vigentes
SELECT v.marca, v.modelo, v.patente, s.compania, s.fecha_vencimiento
FROM vehiculos v
JOIN seguros s ON v.vehiculo_id = s.vehiculo_id
WHERE s.fecha_vencimiento >= GETDATE();

-- 16. Total gastado por pasajero
SELECT u.nombre, u.apellido, SUM(v.costo) AS total_gastado
FROM usuarios u
JOIN usuarios_viajes_tarjetas uvt ON u.usuario_id = uvt.usuario_pasajero_id
JOIN viajes v ON uvt.viaje_id = v.viaje_id
WHERE v.estado = 'finalizado'
GROUP BY u.nombre, u.apellido;

-- 17. Viajes pendientes de un chofer
SELECT v.viaje_id, v.origen, v.destino, v.estado
FROM usuarios_viajes_tarjetas uvt
JOIN viajes v ON uvt.viaje_id = v.viaje_id
WHERE uvt.usuario_chofer_id = 2 AND v.estado = 'pendiente';

-- 18. Suspender un usuario
UPDATE usuarios
SET estado = 'suspendido', actualizado_fecha = GETDATE()
WHERE usuario_id = 1;

-- 19. Eliminar tarjetas vencidas
DELETE FROM tarjetas
WHERE vencimiento < GETDATE();

-- 20. Reporte completo de viajes (chofer, pasajero, vehículo, costo, estado)
SELECT 
  v.viaje_id,
  v.fecha,
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
