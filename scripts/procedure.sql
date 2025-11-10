USE sistema_transporte;   -- Selecciona la base donde estan tus objetos
GO


/* =========================================================
   1) fn_ChoferActivo(@usuario_id INT)
      Devuelve 1 si el usuario existe, es 'chofer' y está 'activo'.
   ========================================================= */
CREATE OR ALTER FUNCTION dbo.fn_ChoferActivo(@usuario_id INT)
RETURNS BIT
AS
BEGIN
    DECLARE @resultado BIT = 0;  -- Valor por defecto

    -- Verifica existencia + tipo + estado del usuario
    IF EXISTS (
        SELECT 1
        FROM usuarios 
        WHERE usuario_id = @usuario_id 
          AND tipo_usuario = 'chofer'
          AND estado = 'activo'
    )
        SET @resultado = 1;

    RETURN @resultado;           -- 1 = OK, 0 = NO
END;
GO

-- PRUEBA RÁPIDA: devuelve 1 si el chofer 4 está activo
SELECT dbo.fn_ChoferActivo(4) AS es_activo;
GO


/* =========================================================
   2) fn_TarjetaVencida(@tarjeta_id INT)
      Devuelve 1 si la tarjeta tiene vencimiento anterior a hoy.
   ========================================================= */
CREATE OR ALTER FUNCTION dbo.fn_TarjetaVencida(@tarjeta_id INT)
RETURNS BIT
AS
BEGIN
    DECLARE @res BIT = 0;

    -- Compara vencimiento con la fecha actual
    IF EXISTS (
        SELECT 1 
        FROM tarjetas 
        WHERE tarjeta_id = @tarjeta_id 
          AND vencimiento < GETDATE()
    )
        SET @res = 1;

    RETURN @res;
END;
GO

-- PRUEBA RÁPIDA: 1 = vencida, 0 = vigente
SELECT dbo.fn_TarjetaVencida(3) AS tarjeta_vencida;
GO


/* =========================================================
   3) fn_CostoEstimado(@distancia FLOAT)
      Calcula un costo simple = distancia * 350.
   ========================================================= */
CREATE OR ALTER FUNCTION dbo.fn_CostoEstimado(@distancia FLOAT)
RETURNS FLOAT
AS
BEGIN
    RETURN @distancia * 350.0;   -- Tarifa base por km
END;
GO

-- PRUEBA RÁPIDA: costo estimado para 12.5 km
SELECT dbo.fn_CostoEstimado(12.5) AS costo_estimado;
GO


/* =========================================================
   4) fn_TieneLicenciaVigente(@usuario_id INT)
      Devuelve 1 si el usuario tiene al menos una licencia vigente.
   ========================================================= */
CREATE OR ALTER FUNCTION dbo.fn_TieneLicenciaVigente(@usuario_id INT)
RETURNS BIT
AS
BEGIN
    DECLARE @result BIT = 0;

    -- Busca licencias no vencidas para ese usuario
    IF EXISTS (
        SELECT 1
        FROM licencias
        WHERE usuario_id = @usuario_id
          AND fecha_vencimiento >= GETDATE()
    )
        SET @result = 1;

    RETURN @result;
END;
GO

-- PRUEBA RÁPIDA: 1 = tiene licencia al día
SELECT dbo.fn_TieneLicenciaVigente(4) AS licencia_vigente;
GO


/* =========================================================
   5) fn_EsViajeFinalizable(@viaje_id INT)
      Devuelve 1 si el viaje está en estado 'en curso'.
   ========================================================= */
CREATE OR ALTER FUNCTION dbo.fn_EsViajeFinalizable(@viaje_id INT)
RETURNS BIT
AS
BEGIN
    DECLARE @ok BIT = 0;

    -- Sólo se puede finalizar si está "en curso"
    IF EXISTS (
        SELECT 1
        FROM viajes
        WHERE viaje_id = @viaje_id 
          AND estado = 'en curso'
    )
        SET @ok = 1;

    RETURN @ok;
END;
GO

-- PRUEBA RÁPIDA: 1 = se puede finalizar
SELECT dbo.fn_EsViajeFinalizable(1) AS finalizable;
GO


/* =========================================================
   6) sp_RegistrarViaje
      Inserta un viaje 'pendiente' validando chofer activo
      y licencia vigente. El chofer está relacionado al vehículo.
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_RegistrarViaje
    @fecha_inicial DATETIMEOFFSET,
    @origen        VARCHAR(150),
    @destino       VARCHAR(150),
    @vehiculo_id   INT,
    @distancia_km  FLOAT    = NULL,
    @costo         FLOAT    = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @chofer INT =
    (	SELECT TOP (1) ch.usuario_id
		FROM usuarios ch
		JOIN usuarios_viajes_tarjetas uvt
		  ON ch.usuario_id = uvt.usuario_chofer_id
		LEFT JOIN calificaciones cal
		  ON cal.viaje_id = uvt.viaje_id
		WHERE ch.tipo_usuario = 'chofer'
		  AND ch.estado = 'activo'
		GROUP BY ch.usuario_id
		ORDER BY AVG(cal.puntuacion) DESC
	);
	
    IF @chofer IS NULL
    BEGIN
        RAISERROR('El vehículo no existe.', 16, 1);
        RETURN;
    END;

    /* 2) Validar que el chofer está activo */
    IF dbo.fn_ChoferActivo(@chofer) = 0
    BEGIN
        RAISERROR('El chofer no esta activo o no existe.', 16, 1);
        RETURN;
    END;

    /* 3) Validar que tenga alguna licencia vigente */
    IF dbo.fn_TieneLicenciaVigente(@chofer) = 0
    BEGIN
        RAISERROR('El chofer no tiene licencia vigente.', 16, 1);
        RETURN;
    END;

    /* 4) Calcular costo si no vino y tenemos distancia */
    IF @costo IS NULL AND @distancia_km IS NOT NULL
        SET @costo = dbo.fn_CostoEstimado(@distancia_km);

    /* 5) Insertar viaje */
    INSERT INTO dbo.viajes
        (fecha_inicial, fecha_final, origen, destino,
         distancia_km, costo, estado, vehiculo_id)
    VALUES
        (@fecha_inicial, NULL, @origen, @destino,
         @distancia_km, @costo, 'pendiente', @vehiculo_id);

END;
GO

-- PRUEBA RÁPIDA (ajustar @vehiculo_id a uno que exista y sea de un chofer activo con licencia vigente):
EXEC dbo.sp_RegistrarViaje
     @fecha_inicial = '2025-11-01T15:00:00-03:00',
     @origen        = 'CABA',
     @destino       = 'La Plata',
     @vehiculo_id   = 10,
     @distancia_km  = 30,
     @costo         = NULL;


-- Ver lo último insertado
SELECT TOP (5) * 
FROM dbo.viajes 
ORDER BY viaje_id DESC;
GO


/* =========================================================
   7) Estado_de_Viajes
      Lista viajes de un chofer filtrando por estado (ej: 'pendiente').
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.Estado_de_Viajes 
    @id_chofer INT = 0,
    @estado    VARCHAR(30) = 'finalizado'
AS
BEGIN 
    SET NOCOUNT ON;

    SELECT 
        v.viaje_id, 
        v.origen, 
        v.destino, 
        v.estado
    FROM usuarios_viajes_tarjetas AS uvt
    JOIN viajes AS v 
      ON uvt.viaje_id = v.viaje_id
    WHERE uvt.usuario_chofer_id = @id_chofer 
      AND v.estado = @estado;
END;
GO

-- PRUEBA: viajes 'pendiente' del chofer 9
EXEC dbo.Estado_de_Viajes @id_chofer = 6, @estado = 'finalizado';
GO
