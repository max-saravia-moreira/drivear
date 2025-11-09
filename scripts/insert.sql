/* ============================================================
   CARGA INICIAL - SISTEMA TRANSPORTE (SQL Server)
   - Sin variables @
   - Comentado paso a paso
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
          (los IDs se consultar�n por email m�s adelante)
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
       4) Veh�culos: asignados a choferes (usuario_id por email)
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
       5) Seguros: uno por veh�culo (vehiculo_id por patente)
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
       7) Viajes: referencian veh�culos (vehiculo_id por patente)
       -------------------------------------------------------- */

    INSERT INTO viajes
    (fecha,origen,destino,hora_inicial,distancia_km,costo,estado,vehiculo_id)
    VALUES
    (CAST(GETDATE() AS DATE),'Buenos Aires','La Plata','08:00',60.5,5000,'finalizado',(SELECT vehiculo_id FROM vehiculos WHERE patente='AA001AA')),
    (DATEADD(DAY,-1,GETDATE()),'Quilmes','Avellaneda','09:00',20.0,1800,'finalizado',(SELECT vehiculo_id FROM vehiculos WHERE patente='AB002AB')),
    (DATEADD(DAY,-2,GETDATE()),'Lanus','Banfield','10:30',15.2,1500,'finalizado',(SELECT vehiculo_id FROM vehiculos WHERE patente='AC003AC')),
    (DATEADD(DAY,-3,GETDATE()),'Morón','Haedo','07:45',8.3,950,'pendiente',(SELECT vehiculo_id FROM vehiculos WHERE patente='AD004AD')),
    (DATEADD(DAY,-4,GETDATE()),'Lomas','Adrogué','12:00',12.0,1200,'en curso',(SELECT vehiculo_id FROM vehiculos WHERE patente='AE005AE')),
    (DATEADD(DAY,-5,GETDATE()),'San Justo','Ciudadela','13:30',10.1,1100,'pendiente',(SELECT vehiculo_id FROM vehiculos WHERE patente='AF006AF')),
    (DATEADD(DAY,-6,GETDATE()),'La Plata','Berisso','14:00',9.0,900,'finalizado',(SELECT vehiculo_id FROM vehiculos WHERE patente='AG007AG')),
    (DATEADD(DAY,-7,GETDATE()),'Temperley','Lanus','15:15',7.5,850,'finalizado',(SELECT vehiculo_id FROM vehiculos WHERE patente='AH008AH')),
    (DATEADD(DAY,-8,GETDATE()),'Moreno','Merlo','16:00',11.0,1000,'pendiente',(SELECT vehiculo_id FROM vehiculos WHERE patente='AI009AI')),
    (DATEADD(DAY,-9,GETDATE()),'CABA','Tigre','17:30',30.0,3000,'pendiente',(SELECT vehiculo_id FROM vehiculos WHERE patente='AJ010AJ'));

    /* --------------------------------------------------------
       8) Usuarios_Viajes_Tarjetas:
          - Chofer / Pasajero por email
          - Viaje por combinaci�n (fecha,origen,destino,hora_inicial)
          - Tarjeta por n�mero
       -------------------------------------------------------- */
    INSERT INTO usuarios_viajes_tarjetas (usuario_chofer_id,usuario_pasajero_id,viaje_id,tarjeta_id)
    VALUES
    (6,1,1,1),
    (7,2,2,2),
	(8,3,3,3),
	(4,4,4,4),
	(10,5,5,5),
	(6,2,6,7),
	(7,3,7,3),
	(6,2,5,5),
	(9,5,9,10),
	(10,1,10,6);

    /* --------------------------------------------------------
       9) Calificaciones: por viaje y creador (pasajero por email)
       -------------------------------------------------------- */
    INSERT INTO calificaciones (puntuacion,comentario,viaje_id,creado_por)
    VALUES
    (5,'Excelente servicio',
        (SELECT v.viaje_id FROM viajes v WHERE v.fecha=CAST(GETDATE() AS DATE) AND v.origen='Buenos Aires' AND v.destino='La Plata' AND v.hora_inicial='08:00'),
        (SELECT usuario_id FROM usuarios WHERE email='ramon@drivear.com')),
    (4,'Buen viaje, puntual',
        (SELECT v.viaje_id FROM viajes v WHERE v.fecha=CAST(DATEADD(DAY,-1,GETDATE()) AS DATE) AND v.origen='Quilmes' AND v.destino='Avellaneda' AND v.hora_inicial='09:00'),
        (SELECT usuario_id FROM usuarios WHERE email='laura@drivear.com')),
    (5,'Muy cómodo y limpio',
        (SELECT v.viaje_id FROM viajes v WHERE v.fecha=CAST(DATEADD(DAY,-2,GETDATE()) AS DATE) AND v.origen='Lanus' AND v.destino='Banfield' AND v.hora_inicial='10:30'),
        (SELECT usuario_id FROM usuarios WHERE email='sofia@drivear.com')),
    (3,'Demora en la salida',
        (SELECT v.viaje_id FROM viajes v WHERE v.fecha=CAST(DATEADD(DAY,-3,GETDATE()) AS DATE) AND v.origen='Morón' AND v.destino='Haedo' AND v.hora_inicial='07:45'),
        (SELECT usuario_id FROM usuarios WHERE email='clara@drivear.com')),
    (4,'Correcto, sin inconvenientes',
        (SELECT v.viaje_id FROM viajes v WHERE v.fecha=CAST(DATEADD(DAY,-4,GETDATE()) AS DATE) AND v.origen='Lomas' AND v.destino='Adrogué' AND v.hora_inicial='12:00'),
        (SELECT usuario_id FROM usuarios WHERE email='paula@drivear.com')),
    (5,'Excelente atención',
        (SELECT v.viaje_id FROM viajes v WHERE v.fecha=CAST(DATEADD(DAY,-5,GETDATE()) AS DATE) AND v.origen='San Justo' AND v.destino='Ciudadela' AND v.hora_inicial='13:30'),
        (SELECT usuario_id FROM usuarios WHERE email='laura@drivear.com')),
    (4,'Todo bien',
        (SELECT v.viaje_id FROM viajes v WHERE v.fecha=CAST(DATEADD(DAY,-6,GETDATE()) AS DATE) AND v.origen='La Plata' AND v.destino='Berisso' AND v.hora_inicial='14:00'),
        (SELECT usuario_id FROM usuarios WHERE email='sofia@drivear.com')),
    (5,'Muy amable el chofer',
        (SELECT v.viaje_id FROM viajes v WHERE v.fecha=CAST(DATEADD(DAY,-7,GETDATE()) AS DATE) AND v.origen='Temperley' AND v.destino='Lanus' AND v.hora_inicial='15:15'),
        (SELECT usuario_id FROM usuarios WHERE email='clara@drivear.com')),
    (3,'Un poco de tráfico, todo ok',
        (SELECT v.viaje_id FROM viajes v WHERE v.fecha=CAST(DATEADD(DAY,-8,GETDATE()) AS DATE) AND v.origen='Moreno' AND v.destino='Merlo' AND v.hora_inicial='16:00'),
        (SELECT usuario_id FROM usuarios WHERE email='paula@drivear.com')),
    (5,'Rápido y seguro',
        (SELECT v.viaje_id FROM viajes v WHERE v.fecha=CAST(DATEADD(DAY,-9,GETDATE()) AS DATE) AND v.origen='CABA' AND v.destino='Tigre' AND v.hora_inicial='17:30'),
        (SELECT usuario_id FROM usuarios WHERE email='ramon@drivear.com'));

    COMMIT;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    THROW;
END CATCH;
GO
