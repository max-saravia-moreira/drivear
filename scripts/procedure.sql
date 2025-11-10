					   
-- 17. Viajes activos en este momento

CREATE PROCEDURE dbo.Estado_de_Viajes 
    @id_chofer int = 0,
    @estado varchar(30) = 'pendiente'
AS
BEGIN 
	SELECT v.viaje_id, v.origen, v.destino, v.estado
	FROM usuarios_viajes_tarjetas uvt
	JOIN viajes v ON uvt.viaje_id = v.viaje_id
	WHERE usuario_chofer_id = @id_chofer AND v.estado = @estado
END;

EXEC Estado_de_Viajes 4, 'pendiente';

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

-- 3. fn_CostoEstimado(@distancia FLOAT)

CREATE FUNCTION fn_CostoEstimado(@distancia FLOAT)
RETURNS FLOAT
AS
BEGIN
    RETURN @distancia * 350; -- precio por km
END;

-- 1. fn_ChoferActivo(@usuario_id INT)

Devuelve 1 si el usuario existe, es chofer y está activo.

CREATE FUNCTION fn_ChoferActivo(@usuario_id INT)
RETURNS BIT
AS
BEGIN
    DECLARE @resultado BIT = 0;

    IF EXISTS (
        SELECT 1 
        FROM usuarios 
        WHERE usuario_id = @usuario_id 
          AND tipo_usuario = 'chofer'
          AND estado = 'activo'
    )
        SET @resultado = 1;

    RETURN @resultado;
END;

-- 2. fn_TarjetaVencida(@tarjeta_id INT)

Devuelve 1 si la tarjeta está vencida.

CREATE FUNCTION fn_TarjetaVencida(@tarjeta_id INT)
RETURNS BIT
AS
BEGIN
    DECLARE @res BIT = 0;

    IF EXISTS (SELECT 1 FROM tarjetas WHERE tarjeta_id = @tarjeta_id AND vencimiento < GETDATE())
        SET @res = 1;

    RETURN @res;
END;

-- 3. fn_CostoEstimado(@distancia FLOAT)

Calcula costo estimado en función de la distancia (ejemplo simple).

CREATE FUNCTION fn_CostoEstimado(@distancia FLOAT)
RETURNS FLOAT
AS
BEGIN
    RETURN @distancia * 350; -- precio por km
END;

-- 4. fn_TieneLicenciaVigente(@usuario_id INT)
CREATE FUNCTION fn_TieneLicenciaVigente(@usuario_id INT)
RETURNS BIT
AS
BEGIN
    DECLARE @result BIT = 0;

    IF EXISTS (
        SELECT 1
        FROM licencias
        WHERE usuario_id = @usuario_id
          AND fecha_vencimiento >= GETDATE()
    )
        SET @result = 1;

    RETURN @result;
END;

-- 5. fn_EsViajeFinalizable(@viaje_id INT)

Chequea si un viaje puede pasar a finalizado.

CREATE FUNCTION fn_EsViajeFinalizable(@viaje_id INT)
RETURNS BIT
AS
BEGIN
    DECLARE @ok BIT = 0;

    IF EXISTS (
        SELECT 1
        FROM viajes
        WHERE viaje_id = @viaje_id 
          AND estado = 'en curso'
    )
        SET @ok = 1;

    RETURN @ok;
END;

-- sp_RegistrarViaje – Crea un viaje validando chofer, vehículo y licencia vigente.
CREATE PROCEDURE sp_RegistrarViaje
    @fecha DATE,
    @origen VARCHAR(150),
    @destino VARCHAR(150),
    @fecha_inicial DATETIME,
    @vehiculo_id INT,
    @creado_por INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @chofer INT =
        (SELECT usuario_id FROM vehiculos WHERE vehiculo_id = @vehiculo_id);

    IF dbo.fn_ChoferActivo(@chofer) = 0
    BEGIN
        RAISERROR('El chofer no está activo o no existe.', 16, 1);
        RETURN;
    END

    IF dbo.fn_TieneLicenciaVigente(@chofer) = 0
    BEGIN
        RAISERROR('El chofer no tiene licencia vigente.', 16, 1);
        RETURN;
    END

    INSERT INTO viajes(fecha, origen, destino, hora_inicial, estado, vehiculo_id, creado_por)
    VALUES (@fecha, @origen, @destino, @hora_inicial, 'pendiente', @vehiculo_id, @creado_por);
END;

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


