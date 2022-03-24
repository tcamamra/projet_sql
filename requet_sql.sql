#Requete N1------------------------------------------------------------------------------
SELECT count(*) as "le nombre total d'appartement vendus au 1er semestre 2020" 
	FROM commune_adresse c, vente v, biens b
	WHERE c.id = b.id
	AND v.id = b.id and type_local= "Appartement" 
    and date_mutation BETWEEN  "2020-01-01 00:00:00" and "2020-06-30 00:00:00";


#Requete N2--------------------------------------------------------------------------------
 select nombre_piece as "nombre de pieces d'appartement", round(count(biens.id)/(select count(biens.id)
 from biens
 join vente 
 on vente.id=biens.id
 where type_local="Appartement")*100,2) as "Proportion des ventes d’appartements"
 from biens
 join vente  
 on vente.id=biens.id
 where type_local="Appartement"
group by nombre_piece
order by nombre_piece;


#Requete N3------------------------------------------------------------------
select  code_departement as 'Liste des 10 départements', 
round(avg(valeur_fonciere / surface_carre),2) as "le prix du mètre carré est le plus élevé"
from biens
join vente  
join commune_adresse 
 on vente.id=biens.id and biens.id=commune_adresse.id
where surface_reelle !=0 and code_departement is not null
group by 1
order by 2  desc
limit 10;
#select count(*) from vente
 
 
#Requete N4------------------------------------------------------------------
select round(avg(valeur_fonciere / surface_carre),2) as 
"Prix moyen du mètre carré d’une maison en Île-de-France "
from vente
join biens
join commune_adresse
on vente.id=biens.id and biens.id=commune_adresse.id
where code_departement in (75,77,78,91,92,93,94,95) and type_local="Maison";

#Requete N5---------------------------------------------------------------------
select vente.id, valeur_fonciere as "prix", code_departement as "Liste des 10 appartements les plus chers dans les departement" , surface_carre as "en nombre de mètres carrés"
from vente
join biens
join commune_adresse
on vente.id=biens.id and biens.id=commune_adresse.id
where type_local ='Appartement' and valeur_fonciere != 0
ORDER BY valeur_fonciere DESC
LIMIT 10; 
#select * from commune_adresse  where code_departement="974";
#Requete N6-----------------------------------------------------
with 
nombre_de_ventes1 AS(
       select count(id) as nbv1
       from vente 
       where date_mutation BETWEEN  "2020-01-01 00:00:00" and "2020-03-31 00:00:00"),
nombre_de_ventes2 AS(
       select count(id) as nbv2
       from vente 
       where date_mutation BETWEEN  "2020-04-01 00:00:00" and "2020-06-30 00:00:00")
select round(((nbv2-nbv1) / nbv1 * 100),2) AS "les ventes entre le premier et le second
trimestre de 2020(taux evolution)"
from nombre_de_ventes1,nombre_de_ventes2;

#Requête 7--------------------------------------------------------
 WITH 
vente_1 AS (
SELECT commune_adresse.commune, COUNT(v.id) AS nombre_vente_t1
FROM vente as v
JOIN biens USING(id)
JOIN commune_adresse USING(id)
WHERE date_mutation BETWEEN "2020-01-01" AND "2020-03-31"
GROUP BY commune
),
vente_2 AS (
	SELECT commune_adresse.commune, count(v.id) AS nombre_vente_t2 
    FROM vente v
    JOIN biens USING(id)
    JOIN commune_adresse USING(id)
    WHERE date_mutation BETWEEN "2020-04-01" AND "2020-06-30"
    GROUP BY commune
)
SELECT commune,  nombre_vente_t1, nombre_vente_t2,
ROUND(((nombre_vente_t2 - nombre_vente_t1) / nombre_vente_t1 * 100),2) AS "Taux evolution du nombre de vente"
FROM vente_1
JOIN vente_2 using(commune)
WHERE ROUND(((nombre_vente_t2 - nombre_vente_t1) / nombre_vente_t2 * 100), 2) > 20;

#requ8-------------------------------------
WITH
appartement_2_p AS (
        SELECT avg(valeur_fonciere /surface_carre) AS 2_P
		FROM vente
		JOIN biens 
		JOIN commune_adresse  
        on vente.id=biens.id and biens.id=commune_adresse.id
		WHERE type_local ='Appartement' AND nombre_piece = 2),
appartement_3_p AS (
		SELECT avg(valeur_fonciere / surface_carre) AS 3_P
		FROM vente
		JOIN biens  
		JOIN  commune_adresse  
        on vente.id=biens.id and biens.id=commune_adresse.id
		WHERE type_local = 'Appartement' AND nombre_piece= 3)
SELECT round ((3_P -2_P)/2_P * 100,2) AS "Différence en pourcentage du prix au mètre carré entre 2P et 3p (Taux d'évolution)"
FROM appartement_2_p, appartement_3_p;

#Requete N9-----------------------------------------------------
WITH commune AS (
     SELECT code_departement, commune, avg(valeur_fonciere) as moyennes
     FROM vente
     JOIN biens  
	 JOIN  commune_adresse  
     on vente.id=biens.id and biens.id=commune_adresse.id
     WHERE code_departement IN (6,13,33,59,69)
     GROUP BY code_departement,commune)
SELECT code_departement AS "code_Département", commune AS "le_nom_de_la_Commune",
round(moyennes ,1) AS "Les moyennes de valeurs foncières "
FROM(
    SELECT code_departement, commune, moyennes,
    rank() OVER (PARTITION BY code_departement ORDER BY moyennes DESC) AS rang
    FROM commune) AS result
WHERE rang <= 3;
#select * from vente