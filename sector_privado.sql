-- Creamos la tabla donde almacenaremos los datos
CREATE TABLE IF NOT EXISTS privado.sector_privado (
    ID INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    Fecha DATE,
    Provincias VARCHAR(100),
    Puestos INT,
    Sueldo_bruto DECIMAL(10, 2),
    Sueldo_neto DECIMAL(10, 2)
);