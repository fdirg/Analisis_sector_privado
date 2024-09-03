-- Sueldo bruto promedio por provincias y su crecimiento a lo largo de los años

WITH Sueldo_bruto_promedio_por_provincia AS (
	SELECT YEAR(sp.Fecha) AS Año, sp.Provincias, AVG(sp.Sueldo_bruto) AS Sueldo_bruto_promedio
    FROM privado.sector_privado sp
    GROUP BY YEAR(sp.Fecha), sp.Provincias
)
SELECT Año, Provincias, Sueldo_bruto_promedio,
CONCAT(ROUND(((Sueldo_bruto_promedio - LAG(Sueldo_bruto_promedio) OVER (PARTITION BY Provincias ORDER BY Año)) / 
                  LAG(Sueldo_bruto_promedio) OVER (PARTITION BY Provincias ORDER BY Año)) * 100, 2), '%') AS Crecimiento_porcentual
FROM Sueldo_bruto_promedio_por_provincia
GROUP BY Año, Provincias
ORDER BY 2 ASC, 3 ASC, 4 ASC;

-- Crecimiento acumulado del sueldo bruto promedio por provincia en todo el periodo analizado

WITH Sueldo_bruto_promedio_por_provincia AS (
	SELECT 
		YEAR(sp.Fecha) AS Año, 
        sp.Provincias, 
        AVG(sp.Sueldo_bruto) AS Sueldo_bruto_promedio
    FROM privado.sector_privado sp
    GROUP BY YEAR(sp.Fecha), sp.Provincias
)
SELECT 
	sbp.Año, 
    sbp.Provincias, 
    sbp.Sueldo_bruto_promedio,
	CONCAT(ROUND((Sueldo_bruto_promedio / FIRST_VALUE(Sueldo_bruto_promedio) OVER (PARTITION BY Provincias ORDER BY Año) - 1) * 100, 2), '%') AS Crecimiento_acumulado
FROM Sueldo_bruto_promedio_por_provincia sbp
ORDER BY sbp.Provincias ASC, sbp.Año ASC;

-- Provincia con mayor sueldo neto promedio a lo largo de los años

WITH Sueldo_neto_promedio AS (
	SELECT YEAR(sp.Fecha) AS Año, sp.Provincias, AVG(sp.Sueldo_neto) AS Sueldo_neto_promedio
    FROM privado.sector_privado sp
    GROUP BY YEAR(sp.Fecha), sp.Provincias
)
SELECT snp.Año, snp.Provincias, snp.Sueldo_neto_promedio AS Maximo_sueldo_neto_promedio
FROM Sueldo_neto_promedio snp
WHERE snp.Sueldo_neto_promedio = (
	SELECT MAX(Sueldo_neto_promedio)
    FROM Sueldo_neto_promedio sub
    WHERE sub.Año = snp.Año
)
ORDER BY snp.Año ASC;

-- Provincia con el menor sueldo neto promedio a lo largo de los años

WITH Sueldo_neto_promedio AS (
	SELECT YEAR(sp.Fecha) AS Año, sp.Provincias, AVG(sp.Sueldo_neto) AS Sueldo_neto_promedio
    FROM privado.sector_privado sp
    GROUP BY YEAR(sp.Fecha), sp.Provincias
)
SELECT snp.Año, snp.Provincias, snp.Sueldo_neto_promedio AS Minimo_sueldo_neto_promedio
FROM Sueldo_neto_promedio snp
WHERE snp.Sueldo_neto_promedio = (
	SELECT MIN(Sueldo_neto_promedio)
    FROM Sueldo_neto_promedio sub
    WHERE sub.Año = snp.Año
)
ORDER BY snp.Año ASC;

-- Analisis de desigualdad salarial entre provincias

SELECT 
    YEAR(sp.Fecha) AS Año,
    ROUND(STDDEV(sp.Sueldo_bruto), 2) AS Desviacion_estandar_sueldo_bruto,
    ROUND(STDDEV(sp.Sueldo_neto), 2) AS Desviacion_estandar_sueldo_neto,
    CONCAT(ROUND((STDDEV(sp.Sueldo_bruto) / AVG(sp.Sueldo_bruto)) * 100, 2), '%') AS Coeficiente_variacion_sueldo_bruto,
    CONCAT(ROUND((STDDEV(sp.Sueldo_neto) / AVG(sp.Sueldo_neto)) * 100, 2), '%') AS Coeficiente_variacion_sueldo_neto
FROM privado.sector_privado sp
GROUP BY YEAR(sp.Fecha)
ORDER BY YEAR(sp.Fecha) ASC;