USE sistema_transporte;
GO

/*  Viajes con todo el detalle */
CREATE VIEW dbo.vw_ViajesDetalle
AS
SELECT
    v.viaje_id,
    v.fecha_inicial,
    v.fecha_final,
    v.origen,
    v.destino,
    v.distancia_km,
    v.costo,
    v.estado,

    -- Vehículo
    vh.vehiculo_id,
    vh.patente,
    vh.marca,
    vh.modelo,

    -- Chofer
    chofer.usuario_id      AS chofer_id,
    CONCAT(chofer.nombre, ' ', chofer.apellido) AS chofer_nombre,

    -- Pasajero
    pas.usuario_id         AS pasajero_id,
    CONCAT(pas.nombre, ' ', pas.apellido) AS pasajero_nombre,

    -- Tarjeta 
    t.tarjeta_id,
    RIGHT(CAST(t.numero_tarjeta AS VARCHAR(19)), 4) AS tarjeta_ultimos4,
    CASE WHEN t.vencimiento < SYSDATETIMEOFFSET() THEN 1 ELSE 0 END AS tarjeta_vencida,

    -- Seguro vigente del vehículo 
    CASE WHEN s_max.fecha_vencimiento >= SYSDATETIMEOFFSET() THEN 1 ELSE 0 END AS seguro_vigente,
    s_max.compania          AS seguro_compania,
    s_max.fecha_vencimiento AS seguro_vencimiento,

    -- Duración en minutos 
    CASE
      WHEN v.fecha_final IS NOT NULL THEN DATEDIFF(MINUTE, v.fecha_inicial, v.fecha_final)
      ELSE NULL
    END AS minutos
FROM dbo.viajes v
INNER JOIN dbo.usuarios_viajes_tarjetas uvt
        ON uvt.viaje_id   = v.viaje_id
INNER JOIN dbo.usuarios chofer
        ON chofer.usuario_id = uvt.usuario_chofer_id
INNER JOIN dbo.usuarios pas
        ON pas.usuario_id    = uvt.usuario_pasajero_id
INNER JOIN dbo.vehiculos vh
        ON vh.vehiculo_id    = v.vehiculo_id
LEFT  JOIN dbo.tarjetas t
        ON t.tarjeta_id      = uvt.tarjeta_id
OUTER APPLY (
    SELECT TOP (1) s.compania, s.fecha_vencimiento
    FROM dbo.seguros s
    WHERE s.vehiculo_id = vh.vehiculo_id
    ORDER BY s.fecha_vencimiento DESC
) AS s_max;
GO

/* Metricas chofer */
CREATE VIEW dbo.vw_MetricasChofer
AS
SELECT
    u.usuario_id                         AS chofer_id,
    CONCAT(u.nombre,' ',u.apellido)      AS chofer_nombre,
    COUNT(DISTINCT v.viaje_id)           AS viajes_totales,
    SUM(CASE WHEN v.estado = 'finalizado' THEN v.costo ELSE 0 END) AS ingresos_finalizados,
    AVG(CAST(c.puntuacion AS FLOAT))     AS promedio_puntuacion
FROM dbo.usuarios u
LEFT JOIN dbo.vehiculos vh
       ON vh.usuario_id = u.usuario_id
LEFT JOIN dbo.viajes v
       ON v.vehiculo_id = vh.vehiculo_id
LEFT JOIN dbo.calificaciones c
       ON c.viaje_id = v.viaje_id
WHERE u.tipo_usuario = 'chofer'
GROUP BY u.usuario_id, CONCAT(u.nombre,' ',u.apellido);
GO

/* Ejemplo de uso */
-- Detalle de viajes 
SELECT TOP (10) * 
FROM dbo.vw_ViajesDetalle
ORDER BY viaje_id DESC;

-- Métricas por chofer 
SELECT *
FROM dbo.vw_MetricasChofer
ORDER BY ingresos_finalizados DESC, viajes_totales DESC;

