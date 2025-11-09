USE sistema_transporte;
GO

/* ====== USUARIOS ====== */
IF OBJECT_ID('dbo.v_usuarios','V') IS NOT NULL DROP VIEW dbo.v_usuarios;
GO
CREATE VIEW dbo.v_usuarios AS
SELECT
  usuario_id,
  cuit_cuil,
  nombre,
  apellido,
  email,
  telefono,
  calle,
  altura,
  codigo_postal,
  tipo_usuario,
  estado,
  /* ocultamos la contraseña */
  CAST(NULL AS VARCHAR(1)) AS contrasena,
  creado_por,
  creado_fecha,
  actualizado_por,
  actualizado_fecha
FROM dbo.usuarios;
GO

/* ====== LICENCIAS ====== */
IF OBJECT_ID('dbo.v_licencias','V') IS NOT NULL DROP VIEW dbo.v_licencias;
GO
CREATE VIEW dbo.v_licencias AS
SELECT
  licencia_id,
  numero_licencia,
  categoria,
  fecha_emision,
  fecha_vencimiento,
  usuario_id,
  creado_por,
  creado_fecha,
  actualizado_por,
  actualizado_fecha
FROM dbo.licencias;
GO

/* ====== VEHICULOS ====== */
IF OBJECT_ID('dbo.v_vehiculos','V') IS NOT NULL DROP VIEW dbo.v_vehiculos;
GO
CREATE VIEW dbo.v_vehiculos AS
SELECT
  vehiculo_id,
  marca,
  modelo,
  color,
  patente,
  anio,
  usuario_id,
  creado_por,
  creado_fecha,
  actualizado_por,
  actualizado_fecha
FROM dbo.vehiculos;
GO

/* ====== SEGUROS (con flag de vigencia) ====== */
IF OBJECT_ID('dbo.v_seguros','V') IS NOT NULL DROP VIEW dbo.v_seguros;
GO
CREATE VIEW dbo.v_seguros AS
SELECT
  seguro_id,
  compania,
  tipo_seguro,
  numero_poliza,
  fecha_vencimiento,
  cobertura_detalle,
  vehiculo_id,
  CASE WHEN fecha_vencimiento >= CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END AS vigente,
  creado_por,
  creado_fecha,
  actualizado_por,
  actualizado_fecha
FROM dbo.seguros;
GO

/* ====== TARJETAS (enmascarado: últimos 4; CVV oculto) ====== */
IF OBJECT_ID('dbo.v_tarjetas','V') IS NOT NULL DROP VIEW dbo.v_tarjetas;
GO
CREATE VIEW dbo.v_tarjetas AS
WITH t AS (
  SELECT
    tarjeta_id,
    /* convertimos a varchar para manipular */
    CAST(numero_tarjeta AS VARCHAR(19)) AS nt_str,
    nombre_titular,
    tipo_tarjeta,
    entidad_bancaria,
    red_pago,
    cvv,
    vencimiento,
    usuario_id,
    creado_por,
    creado_fecha,
    actualizado_por,
    actualizado_fecha
  FROM dbo.tarjetas
)
SELECT
  tarjeta_id,
  -- XXXX-XXXX-XXXX-1234 (enmascarado)
  RIGHT(nt_str, 4)                      AS ultimos_4,
  CONCAT(REPLICATE('X', CASE WHEN LEN(nt_str) > 4 THEN LEN(nt_str) - 4 ELSE 0 END), RIGHT(nt_str,4)) AS numero_enmascarado,
  nombre_titular,
  tipo_tarjeta,
  entidad_bancaria,
  red_pago,
  /* ocultamos CVV */
  CAST(NULL AS INT) AS cvv,
  vencimiento,
  usuario_id,
  creado_por,
  creado_fecha,
  actualizado_por,
  actualizado_fecha
FROM t;
GO

/* ====== VIAJES (con duración en minutos si hay hora_final) ====== */
IF OBJECT_ID('dbo.v_viajes','V') IS NOT NULL DROP VIEW dbo.v_viajes;
GO
CREATE VIEW dbo.v_viajes AS
SELECT
  viaje_id,
  fecha,
  origen,
  destino,
  hora_inicial,
  hora_final,
  distancia_km,
  costo,
  estado,
  vehiculo_id,
  CASE 
    WHEN hora_final IS NOT NULL THEN DATEDIFF(MINUTE, CAST(hora_inicial AS DATETIME), CAST(hora_final AS DATETIME))
    ELSE NULL
  END AS minutos,
  creado_por,
  creado_fecha,
  actualizado_por,
  actualizado_fecha
FROM dbo.viajes;
GO

/* ====== CALIFICACIONES ====== */
IF OBJECT_ID('dbo.v_calificaciones','V') IS NOT NULL DROP VIEW dbo.v_calificaciones;
GO
CREATE VIEW dbo.v_calificaciones AS
SELECT
  calificacion_id,
  puntuacion,
  comentario,
  fecha,
  viaje_id,
  creado_por,
  creado_fecha,
  actualizado_por,
  actualizado_fecha
FROM dbo.calificaciones;
GO

/* ====== USUARIOS_VIAJES_TARJETAS ====== */
IF OBJECT_ID('dbo.v_usuarios_viajes_tarjetas','V') IS NOT NULL DROP VIEW dbo.v_usuarios_viajes_tarjetas;
GO
CREATE VIEW dbo.v_usuarios_viajes_tarjetas AS
SELECT
  uvt_id,
  usuario_chofer_id,
  usuario_pasajero_id,
  viaje_id,
  tarjeta_id,
  creado_por,
  creado_fecha,
  actualizado_por,
  actualizado_fecha
FROM dbo.usuarios_viajes_tarjetas;
GO

CREATE VIEW vw_IngresosPorMes AS
SELECT 
	FORMAT(fecha, 'yyyy-MM') AS mes,
	SUM(costo) AS total_ingresos,
	COUNT(*) AS cantidad_viajes
FROM viajes
WHERE estado = 'finalizado'
GROUP BY FORMAT(fecha, 'yyyy-MM');

/* ====== MOSTRAR VISTAS ====== */
SELECT TOP (10) * FROM dbo.v_usuarios;
SELECT TOP (10) * FROM dbo.v_licencias;
SELECT TOP (10) * FROM dbo.v_vehiculos;
SELECT TOP (10) * FROM dbo.v_seguros;
SELECT TOP (10) * FROM dbo.v_tarjetas;
SELECT TOP (10) * FROM dbo.v_viajes;
SELECT TOP (10) * FROM dbo.v_calificaciones;
SELECT TOP (10) * FROM dbo.v_usuarios_viajes_tarjetas;


