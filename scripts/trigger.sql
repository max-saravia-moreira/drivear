-- Tigger trg_AutorizarFinalizacionViaje

-- Impide finalizar viaje si no está en estado "en curso".

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


