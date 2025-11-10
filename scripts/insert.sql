/* ============================================================
CARGA INICIAL - SISTEMA TRANSPORTE (SQL Server)
============================================================ */

USE sistema_transporte;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRY
BEGIN TRAN;

/* --------------------------------------------------------
0) Limpieza: borrar en orden de dependencias (FK)
Primero tablas hijas, luego las padres
-------------------------------------------------------- */
DELETE FROM calificaciones;
DELETE FROM usuarios_viajes_tarjetas;
DELETE FROM viajes;
DELETE FROM seguros;
DELETE FROM vehiculos;
DELETE FROM licencias;
DELETE FROM tarjetas;
DELETE FROM usuarios;

/* --------------------------------------------------------
1) Reseed de identidades para comenzar desde 1
-------------------------------------------------------- */
DBCC CHECKIDENT ('usuarios', RESEED, 0);
DBCC CHECKIDENT ('licencias', RESEED, 0);
DBCC CHECKIDENT ('vehiculos', RESEED, 0);
DBCC CHECKIDENT ('seguros', RESEED, 0);
DBCC CHECKIDENT ('tarjetas', RESEED, 0);
DBCC CHECKIDENT ('viajes', RESEED, 0);
DBCC CHECKIDENT ('calificaciones', RESEED, 0);
DBCC CHECKIDENT ('usuarios_viajes_tarjetas', RESEED, 0);

/* --------------------------------------------------------
2) Usuarios: 5 pasajeros y 5 choferes
(los IDs se consultaron por email mas adelante)
-------------------------------------------------------- */
	
INSERT INTO usuarios (cuit_cuil,nombre,apellido,email,telefono,calle,altura,codigo_postal,
	tipo_usuario,estado,contrasena)
	VALUES
(20345678902,'Ramon','Lucci','ramon@drivear.com',2222333344,'Av. Caseros',111,1100,'pasajero','activo','pass1'),
(20988765433,'Laura','Perez','laura@drivear.com',1133344455,'Belgrano',321,1000,'pasajero','activo','pass2'),
(20945678901,'Sofia','Gimenez','sofia@drivear.com',1177788899,'Corrientes',654,1700,'pasajero','activo','pass3'),
(20555222333,'Clara','Diaz','clara@drivear.com',1144466677,'Laprida',159,1640,'pasajero','activo','pass4'),
(20999911122,'Paula','Herrera','paula@drivear.com',1133300011,'Italia',888,1400,'pasajero','activo','pass5'),
(27333222119,'Carlos','Gomez','carlos@drivear.com',1167788990,'San Mart�n',456,1638,'chofer','activo','pass6'),
(27455678909,'Mariana','Lopez','mariana@drivear.com',1142233445,'Lavalle',789,1650,'chofer','activo','pass7'),
(27999887766,'Sergio','Martinez','sergio@drivear.com',1161122233,'Rivadavia',777,1800,'chofer','activo','pass8'),
(27888999112,'Andres','Silva','andres@drivear.com',1155566677,'Mitre',222,1900,'chofer','activo','pass9'),
(27876543211,'Leonardo','Mendez','leonardo@drivear.com',1177711122,'Rosales',970,1670,'chofer','activo','pass10');

/* --------------------------------------------------------
3) Licencias: una por chofer (usuario_id por email)
-------------------------------------------------------- */

INSERT INTO licencias (numero_licencia,categoria,fecha_emision,fecha_vencimiento,usuario_id)
VALUES
(700001,'B1','2024-01-10','2028-01-10',(SELECT usuario_id FROM usuarios WHERE email='carlos@drivear.com')),
(700002,'C1','2023-05-12','2027-05-12',(SELECT usuario_id FROM usuarios WHERE email='mariana@drivear.com')),
(700003,'B1','2024-03-20','2028-03-20',(SELECT usuario_id FROM usuarios WHERE email='sergio@drivear.com')),
(700004,'C1','2023-09-01','2027-09-01',(SELECT usuario_id FROM usuarios WHERE email='andres@drivear.com')),
(700005,'D1','2022-07-15','2026-07-15',(SELECT usuario_id FROM usuarios WHERE email='leonardo@drivear.com')),
(700006,'B1','2024-04-10','2028-04-10',(SELECT usuario_id FROM usuarios WHERE email='carlos@drivear.com')),
(700007,'C1','2023-06-25','2027-06-25',(SELECT usuario_id FROM usuarios WHERE email='mariana@drivear.com')),
(700008,'B1','2022-10-08','2026-10-08',(SELECT usuario_id FROM usuarios WHERE email='sergio@drivear.com')),
(700009,'C1','2024-02-12','2028-02-12',(SELECT usuario_id FROM usuarios WHERE email='andres@drivear.com')),
(700010,'B1','2023-12-01','2027-12-01',(SELECT usuario_id FROM usuarios WHERE email='leonardo@drivear.com'));

/* --------------------------------------------------------
4) Vehiculos: asignados a choferes (usuario_id por email)
-------------------------------------------------------- */
INSERT INTO vehiculos (marca,modelo,color,patente,anio,usuario_id)
VALUES
('Toyota','Corolla','Blanco','AA001AA',2022,(SELECT usuario_id FROM usuarios WHERE email='carlos@drivear.com')),
('Ford','Focus','Negro','AB002AB',2021,(SELECT usuario_id FROM usuarios WHERE email='mariana@drivear.com')),
('VW','Gol','Gris','AC003AC',2020,(SELECT usuario_id FROM usuarios WHERE email='sergio@drivear.com')),
('Chevrolet','Onix','Rojo','AD004AD',2023,(SELECT usuario_id FROM usuarios WHERE email='andres@drivear.com')),
('Peugeot','208','Azul','AE005AE',2022,(SELECT usuario_id FROM usuarios WHERE email='leonardo@drivear.com')),
('Nissan','Versa','Negro','AF006AF',2021,(SELECT usuario_id FROM usuarios WHERE email='carlos@drivear.com')),
('Renault','Logan','Blanco','AG007AG',2023,(SELECT usuario_id FROM usuarios WHERE email='mariana@drivear.com')),
('Fiat','Cronos','Rojo','AH008AH',2020,(SELECT usuario_id FROM usuarios WHERE email='sergio@drivear.com')),
('Honda','Civic','Gris','AI009AI',2022,(SELECT usuario_id FROM usuarios WHERE email='andres@drivear.com')),
('Chevrolet','Prisma','Azul','AJ010AJ',2021,(SELECT usuario_id FROM usuarios WHERE email='leonardo@drivear.com'));

/* --------------------------------------------------------
5) Seguros: uno por vehiculo (vehiculo_id por patente)
-------------------------------------------------------- */
INSERT INTO seguros (compania,tipo_seguro,numero_poliza,fecha_vencimiento,cobertura_detalle,vehiculo_id)
VALUES
('Sancor Seguros','Total',900001,DATEADD(MONTH,12,GETDATE()),'Cobertura completa',(SELECT vehiculo_id FROM vehiculos WHERE patente='AA001AA')),
('Allianz','Terceros',900002,DATEADD(MONTH,18,GETDATE()),'RC',(SELECT vehiculo_id FROM vehiculos WHERE patente='AB002AB')),
('La Caja','Total',900003,DATEADD(MONTH,24,GETDATE()),'Completa',(SELECT vehiculo_id FROM vehiculos WHERE patente='AC003AC')),
('Provincia Seguros','Terceros',900004,DATEADD(MONTH,10,GETDATE()),'RC',(SELECT vehiculo_id FROM vehiculos WHERE patente='AD004AD')),
('San Cristobal','Total',900005,DATEADD(MONTH,30,GETDATE()),'Total+Robo',(SELECT vehiculo_id FROM vehiculos WHERE patente='AE005AE')),
('Federacion Patronal','Terceros',900006,DATEADD(MONTH,8,GETDATE()),'Básica',(SELECT vehiculo_id FROM vehiculos WHERE patente='AF006AF')),
('La Caja','Total',900007,DATEADD(MONTH,20,GETDATE()),'Completa',(SELECT vehiculo_id FROM vehiculos WHERE patente='AG007AG')),
('Sura','Terceros',900008,DATEADD(MONTH,14,GETDATE()),'RC+Robo',(SELECT vehiculo_id FROM vehiculos WHERE patente='AH008AH')),
('Mercantil Andina','Total',900009,DATEADD(MONTH,26,GETDATE()),'Completa',(SELECT vehiculo_id FROM vehiculos WHERE patente='AI009AI')),
('Mapfre','Terceros',900010,DATEADD(MONTH,16,GETDATE()),'Básica+Incendio',(SELECT vehiculo_id FROM vehiculos WHERE patente='AJ010AJ'));

/* --------------------------------------------------------
6) Tarjetas: asociadas a pasajeros/usuarios (usuario_id por email)
-------------------------------------------------------- */
INSERT INTO tarjetas
(numero_tarjeta,nombre_titular,tipo_tarjeta,entidad_bancaria,red_pago,cvv,vencimiento,usuario_id)
VALUES
(4111111111111001,'Ramon Lucci','credito','Banco Nación','Visa',123,DATEADD(YEAR,2,GETDATE()),(SELECT usuario_id FROM usuarios WHERE email='ramon@drivear.com')),
(5555555555552002,'Laura Perez','debito','Santander','Mastercard',321,DATEADD(YEAR,1,GETDATE()),(SELECT usuario_id FROM usuarios WHERE email='laura@drivear.com')),
(4111111111113003,'Sofia Gimenez','credito','Galicia','Visa',654,DATEADD(YEAR,2,GETDATE()),(SELECT usuario_id FROM usuarios WHERE email='sofia@drivear.com')),
(5555555555554004,'Clara Diaz','debito','BBVA','Mastercard',777,DATEADD(YEAR,3,GETDATE()),(SELECT usuario_id FROM usuarios WHERE email='clara@drivear.com')),
(4111111111115005,'Paula Herrera','credito','ICBC','Visa',555,DATEADD(MONTH,18,GETDATE()),(SELECT usuario_id FROM usuarios WHERE email='paula@drivear.com')),
(5555555555556006,'Ramon Lucci','debito','Santander','Maestro',999,DATEADD(YEAR,2,GETDATE()),(SELECT usuario_id FROM usuarios WHERE email='ramon@drivear.com')),
(4111111111117007,'Laura Perez','credito','Galicia','Visa',321,DATEADD(YEAR,3,GETDATE()),(SELECT usuario_id FROM usuarios WHERE email='laura@drivear.com')),
(5555555555558008,'Sofia Gimenez','debito','ICBC','Mastercard',888,DATEADD(YEAR,2,GETDATE()),(SELECT usuario_id FROM usuarios WHERE email='sofia@drivear.com')),
(4111111111119009,'Clara Diaz','credito','Banco Nación','Visa',999,DATEADD(YEAR,3,GETDATE()),(SELECT usuario_id FROM usuarios WHERE email='clara@drivear.com')),
(5555555555550010,'Paula Herrera','debito','BBVA','Maestro',123,DATEADD(YEAR,2,GETDATE()),(SELECT usuario_id FROM usuarios WHERE email='paula@drivear.com'));

/* --------------------------------------------------------
7) Viajes: referencian vehiculos (vehiculo_id por patente)
-------------------------------------------------------- */

INSERT INTO viajes
(fecha_inicial, fecha_final, origen, destino, distancia_km, costo, estado, vehiculo_id)
VALUES
-- Finalizado
(SYSDATETIMEOFFSET(), DATEADD(MINUTE, 45, SYSDATETIMEOFFSET()), 'Buenos Aires', 'La Plata', 60.5, 5000, 'finalizado', (SELECT vehiculo_id FROM vehiculos WHERE patente='AA001AA')),
-- Finalizado
(DATEADD(DAY, -1, SYSDATETIMEOFFSET()), DATEADD(MINUTE, 40, DATEADD(DAY, -1, SYSDATETIMEOFFSET())), 'Quilmes', 'Avellaneda', 20.0, 1800, 'finalizado', (SELECT vehiculo_id FROM vehiculos WHERE patente='AB002AB')),
-- Finalizado
(DATEADD(DAY, -2, SYSDATETIMEOFFSET()), DATEADD(MINUTE, 35, DATEADD(DAY, -2, SYSDATETIMEOFFSET())), 'Lanús', 'Banfield', 15.2, 1500, 'finalizado', (SELECT vehiculo_id FROM vehiculos WHERE patente='AC003AC')),
-- Pendiente → sin fecha_final
(DATEADD(DAY, -3, SYSDATETIMEOFFSET()), NULL, 'Morón', 'Haedo', 8.3, 950, 'pendiente', (SELECT vehiculo_id FROM vehiculos WHERE patente='AD004AD')),
-- En curso → sin fecha_final
(DATEADD(DAY, -4, SYSDATETIMEOFFSET()), NULL, 'Lomas', 'Adrogué', 12.0, 1200, 'en curso', (SELECT vehiculo_id FROM vehiculos WHERE patente='AE005AE')),
-- Pendiente → sin fecha_final
(DATEADD(DAY, -5, SYSDATETIMEOFFSET()), NULL, 'San Justo', 'Ciudadela', 10.1, 1100, 'pendiente', (SELECT vehiculo_id FROM vehiculos WHERE patente='AF006AF')),
-- Finalizado
(DATEADD(DAY, -6, SYSDATETIMEOFFSET()), DATEADD(MINUTE, 20, DATEADD(DAY, -6, SYSDATETIMEOFFSET())), 'La Plata', 'Berisso', 9.0, 900, 'finalizado', (SELECT vehiculo_id FROM vehiculos WHERE patente='AG007AG')),
-- Finalizado
(DATEADD(DAY, -7, SYSDATETIMEOFFSET()), DATEADD(MINUTE, 25, DATEADD(DAY, -7, SYSDATETIMEOFFSET())), 'Temperley', 'Lanús', 7.5, 850, 'finalizado', (SELECT vehiculo_id FROM vehiculos WHERE patente='AH008AH')),
-- Pendiente → sin fecha_final
(DATEADD(DAY, -8, SYSDATETIMEOFFSET()), NULL, 'Moreno', 'Merlo', 11.0, 1000, 'pendiente', (SELECT vehiculo_id FROM vehiculos WHERE patente='AI009AI')),
-- Pendiente → sin fecha_final
(DATEADD(DAY, -9, SYSDATETIMEOFFSET()), NULL, 'CABA', 'Tigre', 30.0, 3000, 'pendiente', (SELECT vehiculo_id FROM vehiculos WHERE patente='AJ010AJ'));

/* --------------------------------------------------------
8) Usuarios_Viajes_Tarjetas: CORREGIDO Y VALIDADO
- Usa emails para obtener IDs (más mantenible)
- Cada tarjeta pertenece al pasajero correcto
- Los choferes coinciden con los vehículos de cada viaje
-------------------------------------------------------- */		

INSERT INTO usuarios_viajes_tarjetas (usuario_chofer_id, usuario_pasajero_id, viaje_id, tarjeta_id)
VALUES
-- Viaje 1: Carlos (chofer AA001AA) + Ramon (pasajero) + Tarjeta de Ramon
(
(SELECT usuario_id FROM usuarios WHERE email='carlos@drivear.com'),
(SELECT usuario_id FROM usuarios WHERE email='ramon@drivear.com'),
1,
(SELECT tarjeta_id FROM tarjetas WHERE numero_tarjeta=4111111111111001) -- Tarjeta de Ramon
),
-- Viaje 2: Mariana (chofer AB002AB) + Laura (pasajero) + Tarjeta de Laura
(
(SELECT usuario_id FROM usuarios WHERE email='mariana@drivear.com'),
(SELECT usuario_id FROM usuarios WHERE email='laura@drivear.com'),
2,
(SELECT tarjeta_id FROM tarjetas WHERE numero_tarjeta=5555555555552002) -- Tarjeta de Laura
),
-- Viaje 3: Sergio (chofer AC003AC) + Sofia (pasajero) + Tarjeta de Sofia
(
(SELECT usuario_id FROM usuarios WHERE email='sergio@drivear.com'),
(SELECT usuario_id FROM usuarios WHERE email='sofia@drivear.com'),
3,
(SELECT tarjeta_id FROM tarjetas WHERE numero_tarjeta=4111111111113003) -- Tarjeta de Sofia
),
-- Viaje 4: Andres (chofer AD004AD) + Clara (pasajero) + Tarjeta de Clara
(
(SELECT usuario_id FROM usuarios WHERE email='andres@drivear.com'),
(SELECT usuario_id FROM usuarios WHERE email='clara@drivear.com'),
4,
(SELECT tarjeta_id FROM tarjetas WHERE numero_tarjeta=5555555555554004) -- Tarjeta de Clara
),
-- Viaje 5: Leonardo (chofer AE005AE) + Paula (pasajero) + Tarjeta de Paula
(
(SELECT usuario_id FROM usuarios WHERE email='leonardo@drivear.com'),
(SELECT usuario_id FROM usuarios WHERE email='paula@drivear.com'),
5,
(SELECT tarjeta_id FROM tarjetas WHERE numero_tarjeta=4111111111115005) -- Tarjeta de Paula
),
-- Viaje 6: Carlos (chofer AF006AF) + Laura (pasajero) + Tarjeta #2 de Laura
(
(SELECT usuario_id FROM usuarios WHERE email='carlos@drivear.com'),
(SELECT usuario_id FROM usuarios WHERE email='laura@drivear.com'),
6,
(SELECT tarjeta_id FROM tarjetas WHERE numero_tarjeta=4111111111117007) -- Tarjeta credito de Laura
),
-- Viaje 7: Mariana (chofer AG007AG) + Sofia (pasajero) + Tarjeta de Sofia
(
(SELECT usuario_id FROM usuarios WHERE email='mariana@drivear.com'),
(SELECT usuario_id FROM usuarios WHERE email='sofia@drivear.com'),
7,
(SELECT tarjeta_id FROM tarjetas WHERE numero_tarjeta=4111111111113003) -- Tarjeta de Sofia
),
-- Viaje 8: Sergio (chofer AH008AH) + Ramon (pasajero) + Tarjeta #2 de Ramon
(
(SELECT usuario_id FROM usuarios WHERE email='sergio@drivear.com'),
(SELECT usuario_id FROM usuarios WHERE email='ramon@drivear.com'),
8,
(SELECT tarjeta_id FROM tarjetas WHERE numero_tarjeta=5555555555556006) -- Tarjeta debito de Ramon
),
-- Viaje 9: Andres (chofer AI009AI) + Paula (pasajero) + Tarjeta #2 de Paula
(
(SELECT usuario_id FROM usuarios WHERE email='andres@drivear.com'),
(SELECT usuario_id FROM usuarios WHERE email='paula@drivear.com'),
9,
(SELECT tarjeta_id FROM tarjetas WHERE numero_tarjeta=5555555555550010) -- Tarjeta debito de Paula
),
-- Viaje 10: Leonardo (chofer AJ010AJ) + Ramon (pasajero) + Tarjeta de Ramon
(
(SELECT usuario_id FROM usuarios WHERE email='leonardo@drivear.com'),
(SELECT usuario_id FROM usuarios WHERE email='ramon@drivear.com'),
10,
(SELECT tarjeta_id FROM tarjetas WHERE numero_tarjeta=4111111111111001) -- Tarjeta credito de Ramon
);

/* --------------------------------------------------------
9) Calificaciones: por viaje y creador (pasajero por email)
-------------------------------------------------------- */
	INSERT INTO calificaciones (puntuacion, comentario, viaje_id)
VALUES
(5, 'Excelente servicio', 1),              -- Buenos Aires → La Plata
(4, 'Buen viaje, puntual', 2),             -- Quilmes → Avellaneda
(5, 'Muy cómodo y limpio', 3),             -- Lanús → Banfield
(3, 'Demora en la salida', 4),             -- Morón → Haedo
(4, 'Correcto, sin inconvenientes', 5),    -- Lomas → Adrogué
(5, 'Excelente atención', 6),              -- San Justo → Ciudadela
(4, 'Todo bien', 7),                        -- La Plata → Berisso
(5, 'Muy amable el chofer', 8),            -- Temperley → Lanús
(3, 'Un poco de tráfico, todo ok', 9),     -- Moreno → Merlo
(5, 'Rápido y seguro', 10);                -- CABA → Tigre

COMMIT;
END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0 ROLLBACK;
THROW;
END CATCH;
GO
