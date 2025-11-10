use sistema_transporte;		

/* ---------- 9) Actualizar el estado del viaje a “en curso” ---------- */
UPDATE viajes                                         
SET estado = 'en curso',
    actualizado_fecha = GETDATE()
WHERE viaje_id = 1;

/* ---------------------- 10) Finalizar el viaje ---------------------- */
UPDATE viajes                                         
SET estado = 'finalizado',
    fecha_final = GETDATE(),
    actualizado_fecha = GETDATE()
WHERE viaje_id = 1;

/* -------------------- 18) Suspender un usuario -------------------- */
UPDATE usuarios                                        
SET estado = 'suspendido',                            
    actualizado_fecha = GETDATE() 
WHERE usuario_id = 1; 

/* ---------------- 19) Eliminar tarjetas vencidas ---------------- */
DELETE FROM tarjetas            
WHERE vencimiento < GETDATE();   
