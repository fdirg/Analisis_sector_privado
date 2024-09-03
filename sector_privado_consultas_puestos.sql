-- Evolucion del numero de puestos de trabajo por provincia y año

WITH Suma_puestos AS (
	SELECT 
		YEAR(sp.Fecha) AS Año,
        sp.Provincias,
        SUM(sp.Puestos) AS Total_provincia_puestos
	FROM privado.sector_privado sp
    GROUP BY YEAR(sp.Fecha), sp.Provincias
)
SELECT 
	sump.Año, 
    sump.Provincias, 
    sump.Total_provincia_puestos, 
    (sump.Total_provincia_puestos - LAG(sump.Total_provincia_puestos) OVER (PARTITION BY sump.Provincias ORDER BY sump.Año)) AS Nuevos_puestos_provincia,
	CONCAT(ROUND(
        ( (sump.Total_provincia_puestos - LAG(sump.Total_provincia_puestos) OVER (PARTITION BY sump.Provincias ORDER BY sump.Año)) 
        / LAG(sump.Total_provincia_puestos) OVER (PARTITION BY sump.Provincias ORDER BY sump.Año) 
        ) * 100, 2), '%') AS Porcentaje_crecimiento
FROM Suma_puestos sump
WHERE sump.Año != '2015'
ORDER BY sump.Provincias ASC, sump.Año ASC;

-- Evolucion de los puestos de trabajo a nivel nacional

WITH Suma_puestos_nacional AS (
	SELECT 
		YEAR(sp.Fecha) AS Año,
        'Argentina' AS Pais,
        SUM(sp.Puestos) AS Total_puestos_nacional
	FROM privado.sector_privado sp
    GROUP BY YEAR(sp.Fecha)
)
SELECT 
	spn.Año,
    spn.Pais,
    spn.Total_puestos_nacional,
    (spn.Total_puestos_nacional - LAG(spn.Total_puestos_nacional) OVER (ORDER BY spn.Año)) AS Nuevos_puestos_nacional
FROM Suma_puestos_nacional spn
WHERE spn.Año != '2015'
ORDER BY spn.Año ASC;

-- Estabilidad laboral por provincia

WITH Puestos_inicial AS (
	SELECT 
		sp.Provincias,
        SUM(sp.Puestos) AS Puestos_iniciales
    FROM privado.sector_privado sp
    WHERE YEAR(sp.Fecha) = (SELECT MIN(YEAR(sp2.Fecha)) FROM privado.sector_privado sp2)
    GROUP BY sp.Provincias
),
Puestos_final AS (
	SELECT 
		sp.Provincias,
        SUM(sp.Puestos) AS Puestos_finales
    FROM privado.sector_privado sp
    WHERE YEAR(sp.Fecha) = (SELECT MAX(YEAR(sp2.Fecha)) FROM privado.sector_privado sp2 WHERE YEAR(sp2.Fecha) != '2015')
    GROUP BY sp.Provincias
)
SELECT 
	pi.Provincias,
    CONCAT(ROUND((pf.Puestos_finales - pi.Puestos_iniciales) / pi.Puestos_iniciales * 100, 2), '%') AS Tasa_estabilidad
FROM Puestos_inicial pi
JOIN Puestos_final pf ON pi.Provincias = pf.Provincias
ORDER BY Tasa_estabilidad DESC;