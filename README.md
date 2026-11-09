# SQL-projekt-
Zpracování Projektu na SQL od Engeto.

# SQL Projekt - Analýza dostupnosti potravin v České republice

## Autor

Lukáš Fischer

---

# Zadání projektu

Cílem projektu bylo připravit datové podklady pro analýzu dostupnosti základních potravin v České republice na základě vývoje mezd a cen potravin.

Projekt vychází z veřejně dostupných dat o mzdách, cenách potravin a makroekonomických ukazatelích evropských států.

---

# Použité zdroje dat

## Mzdová data

- czechia_payroll
- czechia_payroll_industry_branch
- czechia_payroll_value_type
- czechia_payroll_calculation

## Cenová data

- czechia_price
- czechia_price_category
- czechia_region

## Makroekonomická data

- countries
- economies

---

# Vytvořené tabulky

## Primární tabulka

### t_lukas_fischer_project_SQL_primary_final

Tabulka obsahuje:

- průměrné mzdy podle ekonomických odvětví
- průměrné ceny potravin
- společné období let 2006–2018

Použitá filtrace:

- value_type_code = 5958 (Průměrná hrubá mzda na zaměstnance)
- calculation_code = 200 (Přepočtený počet zaměstnanců)
- region_code IS NULL (Česká republika)

Do tabulky byly ponechány také záznamy s hodnotou `industry_branch_code IS NULL`, které představují agregovanou průměrnou mzdu za celou Českou republiku.

Výsledná tabulka obsahuje:

- 6840 řádků

---

## Sekundární tabulka

### t_lukas_fischer_project_SQL_secondary_final

Tabulka obsahuje:

- evropské státy
- HDP
- GINI koeficient
- počet obyvatel

pro období let 2006–2018.

Data vznikla spojením tabulek:

- countries
- economies

a následnou filtrací na evropské státy.

---

# Výzkumné otázky a výsledky

## Otázka 1

### Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

Analýza ukázala, že mzdy ve sledovaném období dlouhodobě rostly, avšak nikoliv nepřetržitě ve všech odvětvích.

V několika odvětvích byly zaznamenány meziroční poklesy mezd. Poklesy se objevily například v odvětvích:

- Zemědělství, lesnictví a rybářství
- Těžba a dobývání
- Peněžnictví a pojišťovnictví
- Profesní, vědecké a technické činnosti

### Závěr

Mzdy ve sledovaném období nerostly ve všech odvětvích nepřetržitě. Byly identifikovány roky, ve kterých docházelo k meziročnímu poklesu mezd.

---

## Otázka 2

### Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období?

Byla použita průměrná mzda za Českou republiku (`industry_branch_code IS NULL`).

| Rok | Potravina | Množství |
|------|------|------:|
| 2006 | Chléb konzumní kmínový | 1 212 kg |
| 2018 | Chléb konzumní kmínový | 1 322 kg |
| 2006 | Mléko polotučné pasterované | 1 353 l |
| 2018 | Mléko polotučné pasterované | 1 617 l |

### Závěr

Kupní síla obyvatelstva se mezi lety 2006 a 2018 zvýšila. Za průměrnou mzdu bylo možné pořídit větší množství chleba i mléka než na začátku sledovaného období.

---

## Otázka 3

### Která kategorie potravin zdražuje nejpomaleji?

Pro jednotlivé kategorie potravin byl vypočten průměrný meziroční procentní růst cen.

Nejpomaleji rostoucí kategorií byl:

**Cukr krystalový**

Průměrná meziroční změna ceny:

**-1,92 %**

### Závěr

Cena cukru krystalového ve sledovaném období v průměru klesala, a proto se jedná o kategorii s nejnižším meziročním růstem cen.

---

## Otázka 4

### Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

Pro každý rok byl porovnán:

- růst cen potravin
- růst mezd

Nejvyšší rozdíl byl zaznamenán v roce:

**2013**

| Ukazatel | Hodnota |
|------|------:|
| Růst cen potravin | 5,10 % |
| Růst mezd | -0,13 % |
| Rozdíl | 5,23 p. b. |

### Závěr

Nebyl nalezen žádný rok, ve kterém by růst cen potravin převýšil růst mezd o více než 10 procentních bodů.

---

## Otázka 5

### Má výška HDP vliv na změny ve mzdách a cenách potravin?

Byl analyzován vztah mezi:

- růstem HDP České republiky
- růstem mezd
- růstem cen potravin

### Závěr

Výsledky naznačují částečnou souvislost mezi růstem HDP a růstem mezd. Přímý vztah mezi HDP a cenami potravin se však nepodařilo jednoznačně prokázat.
