
-- Trigger Validar que no se tome un viaje con tarjeta vencida
CREATE TRIGGER trg_ValidarTarjetaVencida
ON viajes
INSTEAD OF INSERT
AS

BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
		SELECT vencimiento FROM viajes v
		LEFT JOIN usuarios_viajes_tarjetas uvt
		ON v.viaje_id = uvt.viaje_id
		LEFT JOIN tarjetas ttcc
		ON uvt.tarjeta_id = ttcc.tarjeta_id
		WHERE vencimiento <= GETDATE()
	)
    BEGIN
        RAISERROR('No se puede utilizar una tarjeta vencida.', 16, 1);
        RETURN;
    END

    SELECT * FROM inserted;
END;


insert into viajes values
('2025-10-31',	'CABA',	'Tigre',	'17:30:00.0000000',NULL,30,3000,'pendiente',10,NULL,GETDATE(),NULL,GETDATE());
exec sp_columns select * from viajes;
GO

USE sistema_transporte;
GO

/* ============================================================
TRIGGER: trg_Viajes_Estado
Tabla: viajes

OBJETIVO:
Controlar y validar las transiciones del estado de un viaje.

REGLAS DE NEGOCIO:
pendiente  -> en curso        (válido)
en curso   -> pendiente       (rollback permitido)
en curso   -> finalizado      (válido)
Un viaje FINALIZADO no puede cambiar a ningún otro estado
No se puede pasar:
        - pendiente -> finalizado
        - finalizado -> en curso / pendiente
        - en curso -> pendiente (SI se permite)
============================================================ */
CREATE OR ALTER TRIGGER dbo.trg_Viajes_Estado
ON dbo.viajes
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    /* =======================================================
       REGLA 0:
       Si el viaje ya estaba FINALIZADO, NO se puede modificar
       ======================================================= */
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted  d ON d.viaje_id = i.viaje_id
        WHERE d.estado = 'finalizado'
          AND i.estado <> d.estado
    )
    BEGIN
        RAISERROR('Un viaje FINALIZADO no puede cambiar de estado.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    /* =======================================================
       REGLA 1:
       Sólo podés finalizar si venís de "en curso"
       (No permitir pendiente -> finalizado)
       ======================================================= */
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted d ON d.viaje_id = i.viaje_id
        WHERE i.estado = 'finalizado'
          AND d.estado <> 'en curso'
    )
    BEGIN
        RAISERROR('Para finalizar un viaje debe venir desde "en curso".', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    /* =======================================================
       REGLA 2:
       Para pasar a "en curso", el estado previo debe ser "pendiente"
       ======================================================= */
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted d ON d.viaje_id = i.viaje_id
        WHERE i.estado = 'en curso'
          AND d.estado <> 'pendiente'
    )
    BEGIN
        RAISERROR('Para pasar a "en curso", el viaje debe estar "pendiente".', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    /* =======================================================
       REGLA 3:
       Se permite rollback:
       en curso -> pendiente
       pero no desde otros estados
       ======================================================= */
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted d ON d.viaje_id = i.viaje_id
        WHERE i.estado = 'pendiente'
          AND d.estado <> 'en curso'
    )
    BEGIN
        RAISERROR('Sólo se puede volver a "pendiente" desde "en curso".', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    /* =======================================================
       UPDATE REAL: sin recursión
       - Completa fecha_final cuando se finaliza
       - Resetea fecha_final cuando se vuelve a pendiente/en curso
       - Actualiza actualizado_fecha siempre
       ======================================================= */
    UPDATE v
       SET v.fecha_inicial = i.fecha_inicial,
           v.fecha_final = CASE
                               WHEN i.estado = 'finalizado' 
                                   THEN COALESCE(i.fecha_final, v.fecha_final, SYSDATETIMEOFFSET())
                               WHEN i.estado IN ('pendiente','en curso')
                                   THEN NULL
                               ELSE i.fecha_final
                           END,
           v.origen = i.origen,
           v.destino = i.destino,
           v.distancia_km = i.distancia_km,
           v.costo = i.costo,
           v.estado = i.estado,
           v.vehiculo_id = i.vehiculo_id,
           v.actualizado_fecha = SYSDATETIMEOFFSET()
    FROM dbo.viajes v
    JOIN inserted i ON i.viaje_id = v.viaje_id;
END;
GO


--DROP TRIGGER IF EXISTS dbo.trg_Viajes_Estado;
--DROP TRIGGER IF EXISTS dbo.trg_ValidarEstadosViaje;
--GO

/* ===========================
   PRUEBAS PARA EL TRIGGER
   =========================== */

select * from viajes;

UPDATE dbo.viajes
SET estado = 'en curso'
WHERE viaje_id = 4;

UPDATE dbo.viajes
SET estado = 'pendiente'
WHERE viaje_id = 4;

UPDATE dbo.viajes
SET estado = 'finalizado'
WHERE viaje_id = 4;







