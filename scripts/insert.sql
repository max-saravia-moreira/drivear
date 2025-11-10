/* ============================================================
CARGA INICIAL - SISTEMA TRANSPORTE (SQL Server)
============================================================ */

USE sistema_transporte;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO


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
DBCC CHECKIDENT ('calificaciones', RESEED, 0);
DBCC CHECKIDENT ('usuarios_viajes_tarjetas', RESEED, 0);
DBCC CHECKIDENT ('viajes', RESEED, 0);
DBCC CHECKIDENT ('seguros', RESEED, 0);
DBCC CHECKIDENT ('vehiculos', RESEED, 0);
DBCC CHECKIDENT ('licencias', RESEED, 0);
DBCC CHECKIDENT ('tarjetas', RESEED, 0);
DBCC CHECKIDENT ('usuarios', RESEED, 0);
/* --------------------------------------------------------
2) Usuarios:
-------------------------------------------------------- */
	
INSERT INTO usuarios (cuit_cuil,nombre,apellido,email,telefono,calle,altura,codigo_postal,
	tipo_usuario,estado,contrasena)
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
(27876543211,'Leonardo','Mendez','leonardo@drivear.com',1177711122,'Rosales',970,1670,'chofer','activo','pass10'),
(27333222889,'Esteban','Fernandez','esteban@drivear.com',1167788990,'Av Gaona',456,1638,'chofer','activo','pass11'),
(27455678999,'Silvio','Leguizamón','silvio@drivear.com',1142233445,'Av. los Incas',789,1650,'chofer','activo','pass12'),
(27999880066,'Saul','Linares','saul@drivear.com',1161122233,'Rosario',777,1800,'chofer','activo','pass13'),
(27884499112,'Benito','Cáseres','benito@drivear.com',1155566677,'Emilio Mitre',222,1900,'chofer','activo','pass14'),
(27876588211,'Agustina','García','agustina@drivear.com',1177711122,'Cachimayo',970,1670,'chofer','activo','pass15');

/* --------------------------------------------------------
3) Licencias: una por chofer (usuario_id por email)
-------------------------------------------------------- */

INSERT INTO licencias (numero_licencia,categoria,fecha_emision,fecha_vencimiento,usuario_id)
VALUES
(700001,'B1','2024-01-10','2028-01-10',6),
(700002,'C1','2023-05-12','2027-05-12',7),
(700003,'B1','2024-03-20','2028-03-20',8),
(700004,'C1','2023-09-01','2027-09-01',9),
(700005,'D1','2022-07-15','2026-07-15',10),
(700006,'B1','2024-01-10','2028-01-10',11),
(700007,'C1','2023-05-12','2027-05-12',12),
(700008,'B1','2024-03-20','2028-03-20',13),
(700009,'C1','2023-09-01','2027-09-01',14),
(700000,'D1','2022-07-15','2026-07-15',15);

/* --------------------------------------------------------
4) Vehiculos: asignados a pasajeros (usuario_id por email)
-------------------------------------------------------- */
INSERT INTO vehiculos (marca,modelo,color,patente,anio,usuario_id)
VALUES
('Toyota','Corolla','Blanco','AA001AA',2022,1),
('Ford','Focus','Negro','AB002AB',2021,2),
('VW','Gol','Gris','AC003AC',2020,3),
('Chevrolet','Onix','Rojo','AD004AD',2023,4),
('Peugeot','208','Azul','AE005AE',2022,5),
('Nissan','Versa','Negro','AF006AF',2021,1),
('Renault','Logan','Blanco','AG007AG',2023,2),
('Fiat','Cronos','Rojo','AH008AH',2020,3),
('Honda','Civic','Gris','AI009AI',2022,4),
('Chevrolet','Prisma','Azul','AJ010AJ',2021,5);

/* --------------------------------------------------------
5) Seguros: uno por vehiculo (vehiculo_id por patente)
-------------------------------------------------------- */
INSERT INTO seguros (compania,tipo_seguro,numero_poliza,fecha_vencimiento,cobertura_detalle,vehiculo_id)
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

/* --------------------------------------------------------
6) Tarjetas: asociadas a pasajeros/usuarios (usuario_id por email)
-------------------------------------------------------- */
INSERT INTO tarjetas
(numero_tarjeta,nombre_titular,tipo_tarjeta,entidad_bancaria,red_pago,cvv,vencimiento,usuario_id)
VALUES
(4111111111111001,'Ramon Lucci','credito','Banco Nación','Visa',123,DATEADD(YEAR,2,GETDATE()),1),
(5555555555552002,'Laura Perez','debito','Santander','Mastercard',321,DATEADD(YEAR,1,GETDATE()),2),
(4111111111113003,'Sofia Gimenez','credito','Galicia','Visa',654,DATEADD(YEAR,2,GETDATE()),3),
(5555555555554004,'Clara Diaz','debito','BBVA','Mastercard',777,DATEADD(YEAR,3,GETDATE()),4),
(4111111111115005,'Paula Herrera','credito','ICBC','Visa',555,DATEADD(MONTH,18,GETDATE()),5),
(5555555555556006,'Ramon Lucci','debito','Santander','Maestro',999,DATEADD(YEAR,2,GETDATE()),6),
(4111111111117007,'Laura Perez','credito','Galicia','Visa',321,DATEADD(YEAR,3,GETDATE()),7),
(5555555555558008,'Sofia Gimenez','debito','ICBC','Mastercard',888,DATEADD(YEAR,2,GETDATE()),8),
(4111111111119009,'Clara Diaz','credito','Banco Nación','Visa',999,DATEADD(YEAR,3,GETDATE()),9),
(5555555555550010,'Paula Herrera','debito','BBVA','Maestro',123,DATEADD(YEAR,2,GETDATE()),10);

/* --------------------------------------------------------
7) Viajes: referencian vehiculos (vehiculo_id por patente)
-------------------------------------------------------- */

INSERT INTO viajes
(fecha_inicial, fecha_final, origen, destino, distancia_km, costo, estado, vehiculo_id)
VALUES
(SYSDATETIMEOFFSET(), DATEADD(MINUTE, 45, SYSDATETIMEOFFSET()), 'Buenos Aires', 'La Plata', 60.5, 5000, 'finalizado', 1),
(DATEADD(DAY, -1, SYSDATETIMEOFFSET()), DATEADD(MINUTE, 40, DATEADD(DAY, -1, SYSDATETIMEOFFSET())), 'Quilmes', 'Avellaneda', 20.0, 1800, 'finalizado', 2),
(DATEADD(DAY, -2, SYSDATETIMEOFFSET()), DATEADD(MINUTE, 35, DATEADD(DAY, -2, SYSDATETIMEOFFSET())), 'Lanús', 'Banfield', 15.2, 1500, 'finalizado', 3),
(DATEADD(DAY, -3, SYSDATETIMEOFFSET()), NULL, 'Morón', 'Haedo', 8.3, 950, 'pendiente', 4),
(DATEADD(DAY, -4, SYSDATETIMEOFFSET()), NULL, 'Lomas', 'Adrogué', 12.0, 1200, 'en curso', 5),
(DATEADD(DAY, -5, SYSDATETIMEOFFSET()), NULL, 'San Justo', 'Ciudadela', 10.1, 1100, 'pendiente', 6),
(DATEADD(DAY, -6, SYSDATETIMEOFFSET()), DATEADD(MINUTE, 20, DATEADD(DAY, -6, SYSDATETIMEOFFSET())), 'La Plata', 'Berisso', 9.0, 900, 'finalizado', 7),
(DATEADD(DAY, -7, SYSDATETIMEOFFSET()), DATEADD(MINUTE, 25, DATEADD(DAY, -7, SYSDATETIMEOFFSET())), 'Temperley', 'Lanús', 7.5, 850, 'finalizado', 8),
(DATEADD(DAY, -8, SYSDATETIMEOFFSET()), NULL, 'Moreno', 'Merlo', 11.0, 1000, 'pendiente', 9),
(DATEADD(DAY, -9, SYSDATETIMEOFFSET()), NULL, 'CABA', 'Tigre', 30.0, 3000, 'pendiente', 10);

/* --------------------------------------------------------
8) Usuarios_Viajes_Tarjetas: CORREGIDO Y VALIDADO
-------------------------------------------------------- */		

INSERT INTO usuarios_viajes_tarjetas (usuario_chofer_id, usuario_pasajero_id, viaje_id, tarjeta_id)
VALUES
(6,1,1,1),
(7,2,2,2),
(8,3,3,3),
(9,4,4,4),
(10,5,5,5),
(11,1,6,1),
(12,2,7,2),
(13,3,8,3),
(14,4,9,4),
(15,5,10,5);

/* --------------------------------------------------------
9) Calificaciones: por viaje y creador (pasajero por email)
-------------------------------------------------------- */
INSERT INTO calificaciones (puntuacion, comentario, viaje_id)
VALUES
(5, 'Excelente servicio', 1),
(4, 'Buen viaje, puntual', 2),
(5, 'Muy cómodo y limpio', 3),
(3, 'Demora en la salida', 4),
(4, 'Correcto, sin inconvenientes', 5),
(5, 'Excelente atención', 6),
(4, 'Todo bien', 7),
(5, 'Muy amable el chofer', 8),
(3, 'Un poco de tráfico, todo ok', 9),
(5, 'Rápido y seguro', 10);
