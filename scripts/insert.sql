USE sistema_transporte;
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
BEGIN TRAN;

-- Limpieza segura
DELETE FROM calificaciones;
DELETE FROM usuarios_viajes_tarjetas;
DELETE FROM viajes;
DELETE FROM tarjetas;
DELETE FROM seguros;
DELETE FROM vehiculos;
DELETE FROM licencias;
DELETE FROM usuarios;

-- reset identity count
DBCC CHECKIDENT('usuarios', RESEED, 0);
DBCC CHECKIDENT('licencias', RESEED, 0);
DBCC CHECKIDENT('vehiculos', RESEED, 0);
DBCC CHECKIDENT('seguros', RESEED, 0);
DBCC CHECKIDENT('tarjetas', RESEED, 0);
DBCC CHECKIDENT('viajes', RESEED, 0);
DBCC CHECKIDENT('calificaciones', RESEED, 0);
DBCC CHECKIDENT('usuarios_viajes_tarjetas', RESEED, 0);

--------------------------------------------------------------------
-- 1. Usuarios (5 pasajeros, 5 choferes)
--------------------------------------------------------------------
INSERT INTO usuarios
(cuit_cuil,nombre,apellido,email,telefono,calle,altura,codigo_postal,tipo_usuario,estado,contrasena)
VALUES
(20345678902,'Ramon','Lucci','ramon@drivear.com',2222333344,'Av. Caseros',111,1100,'pasajero','activo','pass1'),
(20988765433,'Laura','Perez','laura@drivear.com',1133344455,'Belgrano',321,1000,'pasajero','activo','pass2'),
(20945678901,'Sofia','Gimenez','sofia@drivear.com',1177788899,'Corrientes',654,1700,'pasajero','activo','pass3'),
(20555222333,'Clara','Diaz','clara@drivear.com',1144466677,'Laprida',159,1640,'pasajero','activo','pass4'),
(20999911122,'Paula','Herrera','paula@drivear.com',1133300011,'Italia',888,1400,'pasajero','activo','pass5'),
(27333222119,'Carlos','Gomez','carlos@drivear.com',1167788990,'San Martín',456,1638,'chofer','activo','pass6'),
(27455678909,'Mariana','Lopez','mariana@drivear.com',1142233445,'Lavalle',789,1650,'chofer','activo','pass7'),
(27999887766,'Sergio','Martinez','sergio@drivear.com',1161122233,'Rivadavia',777,1800,'chofer','activo','pass8'),
(27888999112,'Andres','Silva','andres@drivear.com',1155566677,'Mitre',222,1900,'chofer','activo','pass9'),
(27876543211,'Leonardo','Mendez','leonardo@drivear.com',1177711122,'Rosales',970,1670,'chofer','activo','pass10');

-- 2. Guardar variables
DECLARE @p1 INT=(SELECT usuario_id FROM usuarios WHERE email='ramon@drivear.com');
DECLARE @p2 INT=(SELECT usuario_id FROM usuarios WHERE email='laura@drivear.com');
DECLARE @p3 INT=(SELECT usuario_id FROM usuarios WHERE email='sofia@drivear.com');
DECLARE @p4 INT=(SELECT usuario_id FROM usuarios WHERE email='clara@drivear.com');
DECLARE @p5 INT=(SELECT usuario_id FROM usuarios WHERE email='paula@drivear.com');
DECLARE @c1 INT=(SELECT usuario_id FROM usuarios WHERE email='carlos@drivear.com');
DECLARE @c2 INT=(SELECT usuario_id FROM usuarios WHERE email='mariana@drivear.com');
DECLARE @c3 INT=(SELECT usuario_id FROM usuarios WHERE email='sergio@drivear.com');
DECLARE @c4 INT=(SELECT usuario_id FROM usuarios WHERE email='andres@drivear.com');
DECLARE @c5 INT=(SELECT usuario_id FROM usuarios WHERE email='leonardo@drivear.com');

--------------------------------------------------------------------
-- 2. Licencias (una por chofer)
--------------------------------------------------------------------
INSERT INTO licencias
(numero_licencia,categoria,fecha_emision,fecha_vencimiento,usuario_id)
VALUES
(700001,'B1','2024-01-10','2028-01-10',@c1),
(700002,'C1','2023-05-12','2027-05-12',@c2),
(700003,'B1','2024-03-20','2028-03-20',@c3),
(700004,'C1','2023-09-01','2027-09-01',@c4),
(700005,'D1','2022-07-15','2026-07-15',@c5),
(700006,'B1','2024-04-10','2028-04-10',@c1),
(700007,'C1','2023-06-25','2027-06-25',@c2),
(700008,'B1','2022-10-08','2026-10-08',@c3),
(700009,'C1','2024-02-12','2028-02-12',@c4),
(700010,'B1','2023-12-01','2027-12-01',@c5);

--------------------------------------------------------------------
-- 3. Vehículos (10)
--------------------------------------------------------------------
INSERT INTO vehiculos
(marca,modelo,color,patente,anio,usuario_id)
VALUES
('Toyota','Corolla','Blanco','AA001AA',2022,@c1),
('Ford','Focus','Negro','AB002AB',2021,@c2),
('VW','Gol','Gris','AC003AC',2020,@c3),
('Chevrolet','Onix','Rojo','AD004AD',2023,@c4),
('Peugeot','208','Azul','AE005AE',2022,@c5),
('Nissan','Versa','Negro','AF006AF',2021,@c1),
('Renault','Logan','Blanco','AG007AG',2023,@c2),
('Fiat','Cronos','Rojo','AH008AH',2020,@c3),
('Honda','Civic','Gris','AI009AI',2022,@c4),
('Chevrolet','Prisma','Azul','AJ010AJ',2021,@c5);

--------------------------------------------------------------------
-- 4. Seguros (10)
--------------------------------------------------------------------
INSERT INTO seguros
(compania,tipo_seguro,numero_poliza,fecha_vencimiento,cobertura_detalle,vehiculo_id)
VALUES
('Sancor Seguros','Total',900001,DATEADD(MONTH,12,GETDATE()),'Cobertura completa',1),
('Allianz','Terceros',900002,DATEADD(MONTH,18,GETDATE()),'RC',2),
('La Caja','Total',900003,DATEADD(MONTH,24,GETDATE()),'Completa',3),
('Provincia Seguros','Terceros',900004,DATEADD(MONTH,10,GETDATE()),'RC',4),
('San Cristobal','Total',900005,DATEADD(MONTH,30,GETDATE()),'Total+Robo',5),
('Federacion Patronal','Terceros',900006,DATEADD(MONTH,8,GETDATE()),'Básica',6),
('La Caja','Total',900007,DATEADD(MONTH,20,GETDATE()),'Completa',7),
('Sura','Terceros',900008,DATEADD(MONTH,14,GETDATE()),'RC+Robo',8),
('Mercantil Andina','Total',900009,DATEADD(MONTH,26,GETDATE()),'Completa',9),
('Mapfre','Terceros',900010,DATEADD(MONTH,16,GETDATE()),'Básica+Incendio',10);

--------------------------------------------------------------------
-- 5. Tarjetas (10)
--------------------------------------------------------------------
INSERT INTO tarjetas
(numero_tarjeta,nombre_titular,tipo_tarjeta,entidad_bancaria,red_pago,cvv,vencimiento,usuario_id)
VALUES
(4111111111111001,'Ramon Lucci','credito','Banco Nación','Visa',123,DATEADD(YEAR,2,GETDATE()),@p1),
(5555555555552002,'Laura Perez','debito','Santander','Mastercard',321,DATEADD(YEAR,1,GETDATE()),@p2),
(4111111111113003,'Sofia Gimenez','credito','Galicia','Visa',654,DATEADD(YEAR,2,GETDATE()),@p3),
(5555555555554004,'Clara Diaz','debito','BBVA','Mastercard',777,DATEADD(YEAR,3,GETDATE()),@p4),
(4111111111115005,'Paula Herrera','credito','ICBC','Visa',555,DATEADD(MONTH,18,GETDATE()),@p5),
(5555555555556006,'Ramon Lucci','debito','Santander','Maestro',999,DATEADD(YEAR,2,GETDATE()),@p1),
(4111111111117007,'Laura Perez','credito','Galicia','Visa',321,DATEADD(YEAR,3,GETDATE()),@p2),
(5555555555558008,'Sofia Gimenez','debito','ICBC','Mastercard',888,DATEADD(YEAR,2,GETDATE()),@p3),
(4111111111119009,'Clara Diaz','credito','Banco Nación','Visa',999,DATEADD(YEAR,3,GETDATE()),@p4),
(5555555555550010,'Paula Herrera','debito','BBVA','Maestro',123,DATEADD(YEAR,2,GETDATE()),@p5);

--------------------------------------------------------------------
-- 6. Viajes (10)
--------------------------------------------------------------------
INSERT INTO viajes
(fecha,origen,destino,hora_inicial,distancia_km,costo,estado,vehiculo_id)
VALUES
(CAST(GETDATE() AS DATE),'Buenos Aires','La Plata','08:00',60.5,5000,'finalizado',1),
(DATEADD(DAY,-1,GETDATE()),'Quilmes','Avellaneda','09:00',20.0,1800,'finalizado',2),
(DATEADD(DAY,-2,GETDATE()),'Lanus','Banfield','10:30',15.2,1500,'finalizado',3),
(DATEADD(DAY,-3,GETDATE()),'Morón','Haedo','07:45',8.3,950,'pendiente',4),
(DATEADD(DAY,-4,GETDATE()),'Lomas','Adrogué','12:00',12.0,1200,'en curso',5),
(DATEADD(DAY,-5,GETDATE()),'San Justo','Ciudadela','13:30',10.1,1100,'pendiente',6),
(DATEADD(DAY,-6,GETDATE()),'La Plata','Berisso','14:00',9.0,900,'finalizado',7),
(DATEADD(DAY,-7,GETDATE()),'Temperley','Lanus','15:15',7.5,850,'finalizado',8),
(DATEADD(DAY,-8,GETDATE()),'Moreno','Merlo','16:00',11.0,1000,'pendiente',9),
(DATEADD(DAY,-9,GETDATE()),'CABA','Tigre','17:30',30.0,3000,'pendiente',10);

--------------------------------------------------------------------
-- 7. Usuarios_Viajes_Tarjetas (10)
--------------------------------------------------------------------
INSERT INTO usuarios_viajes_tarjetas
(usuario_chofer_id,usuario_pasajero_id,viaje_id,tarjeta_id)
VALUES
(@c1,@p1,1,1),
(@c2,@p2,2,2),
(@c3,@p3,3,3),
(@c4,@p4,4,4),
(@c5,@p5,5,5),
(@c1,@p2,6,7),
(@c2,@p3,7,3),
(@c3,@p4,8,9),
(@c4,@p5,9,10),
(@c5,@p1,10,6);

--------------------------------------------------------------------
-- 8. Calificaciones (10)
--------------------------------------------------------------------
INSERT INTO calificaciones
(puntuacion,comentario,viaje_id,creado_por)
VALUES
(5,'Excelente servicio',1,@p1),
(4,'Buen viaje, puntual',2,@p2),
(5,'Muy cómodo y limpio',3,@p3),
(3,'Demora en la salida',4,@p4),
(4,'Correcto, sin inconvenientes',5,@p5),
(5,'Excelente atención',6,@p2),
(4,'Todo bien',7,@p3),
(5,'Muy amable el chofer',8,@p4),
(3,'Un poco de tráfico, todo ok',9,@p5),
(5,'Rápido y seguro',10,@p1);

COMMIT;
END TRY
BEGIN CATCH
  IF @@TRANCOUNT>0 ROLLBACK;
  THROW;
END CATCH;
GO
