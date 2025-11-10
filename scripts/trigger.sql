
-- Trigger Validar que no se tome un viaje con tarjeta vencida
/* Bloquea asociar una tarjeta vencida en NUEVAS filas de uvt */
CREATE OR ALTER TRIGGER dbo.trg_BloquearTarjetaVencida
ON dbo.usuarios_viajes_tarjetas
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Si alguna de las filas reci�n insertadas usa tarjeta vencida => error
    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        INNER JOIN dbo.tarjetas AS t
            ON t.tarjeta_id = i.tarjeta_id
        WHERE t.vencimiento < SYSDATETIMEOFFSET()   -- tus columnas son DATETIMEOFFSET
    )
    BEGIN
        RAISERROR(N'No se puede utilizar una tarjeta vencida.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;

SELECT
    uvt.uvt_id,
    uvt.usuario_chofer_id,
    uvt.usuario_pasajero_id,
    uvt.tarjeta_id,
	t.numero_tarjeta,
    t.vencimiento
FROM usuarios_viajes_tarjetas AS uvt
LEFT JOIN tarjetas AS t
    ON uvt.tarjeta_id = t.tarjeta_id;

--ALTER TABLE dbo.tarjetas NOCHECK CONSTRAINT chk_tarjeta_vencimiento;
--ALTER TABLE dbo.tarjetas WITH CHECK CHECK CONSTRAINT chk_tarjeta_vencimiento;

UPDATE dbo.tarjetas
SET vencimiento = '2010-01-01T00:00:00+00:00'  -- fecha antigua para asegurar vencimiento
WHERE tarjeta_id = 5;


-- Intento de inserci�n que debe fallar y producir rollback
INSERT INTO dbo.usuarios_viajes_tarjetas
    (usuario_chofer_id, usuario_pasajero_id, viaje_id, tarjeta_id)
VALUES
    (10, 5, 11, 5);  -- tarjeta_id = 5 fue marcada vencida arriba




USE sistema_transporte;
GO

/* ============================================================
TRIGGER: trg_Viajes_Estado
Tabla: viajes

OBJETIVO:
Controlar y validar las transiciones del estado de un viaje.

REGLAS DE NEGOCIO:
pendiente  -> en curso        (v�lido)
en curso   -> pendiente       (rollback permitido)
en curso   -> finalizado      (v�lido)
Un viaje FINALIZADO no puede cambiar a ning�n otro estado
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
       S�lo pod�s finalizar si ven�s de "en curso"
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
        RAISERROR('S�lo se puede volver a "pendiente" desde "en curso".', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    /* =======================================================
       UPDATE REAL:
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







