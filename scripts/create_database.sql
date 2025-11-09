IF NOT EXISTS (
    SELECT name 
    FROM sys.databases 
    WHERE name = 'sistema_transporte'
)
BEGIN
    CREATE DATABASE sistema_transporte;
	ALTER DATABASE sistema_transporte COLLATE LATIN1_GENERAL_100_CI_AS_SC_UTF8;
END
GO

USE sistema_transporte;
GO
CREATE TABLE usuarios (
  usuario_id INT IDENTITY(1,1) PRIMARY KEY,
  cuit_cuil BIGINT NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL,
  telefono BIGINT,
  calle VARCHAR(150),
  altura INT,
  codigo_postal INT,
  tipo_usuario VARCHAR(50) CHECK (tipo_usuario IN ('chofer', 'pasajero')),
  estado VARCHAR(50) CHECK (estado IN ('activo', 'inactivo', 'suspendido')),
  contrasena VARCHAR(255) NOT NULL,
  creado_por INT NULL,
  creado_fecha DATETIME DEFAULT GETDATE(),
  actualizado_por INT NULL,
  actualizado_fecha DATETIME DEFAULT GETDATE(),

  CONSTRAINT uq_usuario_email UNIQUE (email),
  CONSTRAINT uq_usuario_cuit UNIQUE (cuit_cuil),
  CONSTRAINT fk_usuario_creado_por FOREIGN KEY (creado_por) REFERENCES usuarios(usuario_id),
  CONSTRAINT fk_usuario_actualizado_por FOREIGN KEY (actualizado_por) REFERENCES usuarios(usuario_id)
);


CREATE TABLE licencias (
  licencia_id INT IDENTITY(1,1) PRIMARY KEY,
  numero_licencia INT NOT NULL,
  categoria VARCHAR(50) NOT NULL,
  fecha_emision DATE NOT NULL,
  fecha_vencimiento DATE NOT NULL,
  usuario_id INT NOT NULL,
  creado_por INT,
  creado_fecha DATETIME DEFAULT GETDATE(),
  actualizado_por INT,
  actualizado_fecha DATETIME DEFAULT GETDATE(),

  CONSTRAINT uq_licencia_numero UNIQUE (numero_licencia),
  CONSTRAINT fk_licencia_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id),
  CONSTRAINT fk_licencia_creado_por FOREIGN KEY (creado_por) REFERENCES usuarios(usuario_id),
  CONSTRAINT fk_licencia_actualizado_por FOREIGN KEY (actualizado_por) REFERENCES usuarios(usuario_id),
  CONSTRAINT chk_licencia_fechas CHECK (fecha_vencimiento > fecha_emision)
);

CREATE TABLE vehiculos (
  vehiculo_id INT IDENTITY(1,1) PRIMARY KEY,
  marca VARCHAR(100) NOT NULL,
  modelo VARCHAR(100) NOT NULL,
  color VARCHAR(50),
  patente VARCHAR(20) NOT NULL,
  anio INT NOT NULL,
  usuario_id INT NOT NULL,
  creado_por INT,
  creado_fecha DATETIME DEFAULT GETDATE(),
  actualizado_por INT,
  actualizado_fecha DATETIME DEFAULT GETDATE(),

  CONSTRAINT uq_vehiculo_patente UNIQUE (patente),
  CONSTRAINT fk_vehiculo_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id),
  CONSTRAINT fk_vehiculo_creado_por FOREIGN KEY (creado_por) REFERENCES usuarios(usuario_id),
  CONSTRAINT fk_vehiculo_actualizado_por FOREIGN KEY (actualizado_por) REFERENCES usuarios(usuario_id)
);

CREATE TABLE seguros (
  seguro_id INT IDENTITY(1,1) PRIMARY KEY,
  compania VARCHAR(100) NOT NULL,
  tipo_seguro VARCHAR(100) NOT NULL,
  numero_poliza INT NOT NULL,
  fecha_vencimiento DATE NOT NULL,
  cobertura_detalle VARCHAR(255),
  vehiculo_id INT NOT NULL,
  creado_por INT,
  creado_fecha DATETIME DEFAULT GETDATE(),
  actualizado_por INT,
  actualizado_fecha DATETIME DEFAULT GETDATE(),

  CONSTRAINT uq_seguro_poliza UNIQUE (numero_poliza),
  CONSTRAINT fk_seguro_vehiculo FOREIGN KEY (vehiculo_id) REFERENCES vehiculos(vehiculo_id),
  CONSTRAINT fk_seguro_creado_por FOREIGN KEY (creado_por) REFERENCES usuarios(usuario_id),
  CONSTRAINT fk_seguro_actualizado_por FOREIGN KEY (actualizado_por) REFERENCES usuarios(usuario_id),
  CONSTRAINT chk_seguro_vencimiento CHECK (fecha_vencimiento >= GETDATE())
);

CREATE TABLE tarjetas (
  tarjeta_id INT IDENTITY(1,1) PRIMARY KEY,
  numero_tarjeta BIGINT NOT NULL,
  nombre_titular VARCHAR(150) NOT NULL,
  tipo_tarjeta VARCHAR(50) CHECK (tipo_tarjeta IN ('debito', 'credito')),
  entidad_bancaria VARCHAR(100),
  red_pago VARCHAR(50),
  cvv INT CHECK (cvv BETWEEN 100 AND 9999),
  vencimiento DATE NOT NULL,
  usuario_id INT NOT NULL,

  creado_por INT,
  creado_fecha DATETIME DEFAULT GETDATE(),
  actualizado_por INT,
  actualizado_fecha DATETIME DEFAULT GETDATE(),

  CONSTRAINT uq_tarjeta_numero UNIQUE (numero_tarjeta),
  CONSTRAINT fk_tarjeta_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id),
  CONSTRAINT fk_tarjeta_creado_por FOREIGN KEY (creado_por) REFERENCES usuarios(usuario_id),
  CONSTRAINT fk_tarjeta_actualizado_por FOREIGN KEY (actualizado_por) REFERENCES usuarios(usuario_id),
  CONSTRAINT chk_tarjeta_vencimiento CHECK (vencimiento >= GETDATE())
);

CREATE TABLE viajes (
  viaje_id INT IDENTITY(1,1) PRIMARY KEY,
  fecha DATE NOT NULL,
  origen VARCHAR(150) NOT NULL,
  destino VARCHAR(150) NOT NULL,
  hora_inicial TIME NOT NULL,
  hora_final TIME,
  distancia_km FLOAT CHECK (distancia_km >= 0),
  costo FLOAT CHECK (costo >= 0),
  estado VARCHAR(50) CHECK (estado IN ('pendiente', 'en curso', 'finalizado', 'cancelado')),
  vehiculo_id INT NOT NULL,

  creado_por INT,
  creado_fecha DATETIME DEFAULT GETDATE(),
  actualizado_por INT,
  actualizado_fecha DATETIME DEFAULT GETDATE(),

  CONSTRAINT fk_viaje_vehiculo FOREIGN KEY (vehiculo_id) REFERENCES vehiculos(vehiculo_id),
  CONSTRAINT fk_viaje_creado_por FOREIGN KEY (creado_por) REFERENCES usuarios(usuario_id),
  CONSTRAINT fk_viaje_actualizado_por FOREIGN KEY (actualizado_por) REFERENCES usuarios(usuario_id)
);


CREATE TABLE calificaciones (
  calificacion_id INT IDENTITY(1,1) PRIMARY KEY,
  puntuacion INT CHECK (puntuacion BETWEEN 1 AND 5),
  comentario VARCHAR(255),
  fecha DATE DEFAULT (GETDATE()),
  viaje_id INT NOT NULL,

  creado_por INT,
  creado_fecha DATETIME DEFAULT GETDATE(),
  actualizado_por INT,
  actualizado_fecha DATETIME DEFAULT GETDATE(),

  CONSTRAINT fk_calificacion_viaje FOREIGN KEY (viaje_id) REFERENCES viajes(viaje_id),
  CONSTRAINT fk_calificacion_creado_por FOREIGN KEY (creado_por) REFERENCES usuarios(usuario_id),
  CONSTRAINT fk_calificacion_actualizado_por FOREIGN KEY (actualizado_por) REFERENCES usuarios(usuario_id)
);

CREATE TABLE usuarios_viajes_tarjetas (
  uvt_id INT IDENTITY(1,1) PRIMARY KEY,
  usuario_chofer_id INT NOT NULL,
  usuario_pasajero_id INT NOT NULL,
  viaje_id INT NOT NULL,
  tarjeta_id INT NOT NULL,

  creado_por INT,
  creado_fecha DATETIME DEFAULT GETDATE(),
  actualizado_por INT,
  actualizado_fecha DATETIME DEFAULT GETDATE(),

  CONSTRAINT uq_uvt UNIQUE (usuario_chofer_id, usuario_pasajero_id, viaje_id, tarjeta_id),
  CONSTRAINT fk_uvt_chofer FOREIGN KEY (usuario_chofer_id) REFERENCES usuarios(usuario_id),
  CONSTRAINT fk_uvt_pasajero FOREIGN KEY (usuario_pasajero_id) REFERENCES usuarios(usuario_id),
  CONSTRAINT fk_uvt_viaje FOREIGN KEY (viaje_id) REFERENCES viajes(viaje_id),
  CONSTRAINT fk_uvt_tarjeta FOREIGN KEY (tarjeta_id) REFERENCES tarjetas(tarjeta_id),
  CONSTRAINT fk_uvt_creado_por FOREIGN KEY (creado_por) REFERENCES usuarios(usuario_id),
  CONSTRAINT fk_uvt_actualizado_por FOREIGN KEY (actualizado_por) REFERENCES usuarios(usuario_id)
);
