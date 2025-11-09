-- 1) Para diferenciar rápido chofer vs pasajero
CREATE INDEX idx_usuarios_tipo_usuario ON usuarios(tipo_usuario);
 
-- 2) Para buscar licencias por usuario (JOIN muy frecuente)
CREATE INDEX idx_licencias_usuario_id ON licencias(usuario_id);
 
-- 3) Para traer vehículos del chofer
CREATE INDEX idx_vehiculos_usuario_id ON vehiculos(usuario_id);
 
-- 4) Para obtener viajes realizados por un vehículo (y por lo tanto por un chofer)
CREATE INDEX idx_viajes_vehiculo_id ON viajes(vehiculo_id);
 
-- 5) Para obtener calificaciones de un viaje
CREATE INDEX idx_calificaciones_viaje_id ON calificaciones(viaje_id);