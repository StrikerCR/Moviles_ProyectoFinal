drop database if exists ESCOMBROSpy;
create database ESCOMBROSpy;
use ESCOMBROSpy;

DROP TABLE IF EXISTS alumno;

CREATE TABLE alumno (
  noBoleta varchar(10) NOT NULL,
  nombre_es varchar(50) NOT NULL,
  contraseña varchar(50) NOT NULL,
  correo varchar(128) NOT NULL,
  PRIMARY KEY (noBoleta)
);

insert into alumno(noBoleta, nombre_es, contraseña, correo) values
("2022630203", "Rafael Cabañas Rocha", "ch1chen0l", "rcabanasr28@gmail.com"),
("2022630240", "Diana Paola Fernández Baños", "burbujas26", "dfernandezb26@gmail.com"),
("2022630001", "Maximo Rocha Baños", "caradebola", "max@max.com");