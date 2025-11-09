use sistema_transporte;		

/* ---------- 9) Actualizar el estado del viaje a “en curso” ---------- */
UPDATE viajes                                         
SET estado = 'en curso',                              -- Cambia el estado del viaje a 'en curso'.
    actualizado_fecha = GETDATE()                     -- Registra la fecha/hora actual de la actualización.
WHERE viaje_id = 1;                                   -- Afecta solo al viaje con ID = 1.

/* ---------------------- 10) Finalizar el viaje ---------------------- */
UPDATE viajes                                         
SET estado = 'finalizado',                            -- Cambia el estado a 'finalizado'.
    hora_final = '09:00',                             -- Guarda la hora de finalización (formato TIME válido).
    actualizado_fecha = GETDATE()                     -- Sella la fecha/hora de la modificación.
WHERE viaje_id = 1;                                   -- Mismo viaje: ID = 1.

/* -------------------- 18) Suspender un usuario -------------------- */
UPDATE usuarios                                        -- Tabla de usuarios.
SET estado = 'suspendido',                             -- Pasa el estado a 'suspendido'.
    actualizado_fecha = GETDATE()                      -- Fecha/hora de actualización.
WHERE usuario_id = 1;                                  -- Usuario afectado: ID = 1.

/* ---------------- 19) Eliminar tarjetas vencidas ---------------- */
DELETE FROM tarjetas                                   -- Borra filas de la tabla tarjetas…
WHERE vencimiento < GETDATE();                         -- …cuyas fechas de vencimiento ya pasaron.
