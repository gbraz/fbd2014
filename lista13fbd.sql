--Lista 13 - FBD
--Aluno: Geraldo Braz Duarte Filho
--Matrícula: 354063

--**1. Recuperar o nome do departamento com maior média salarial.

select d.dnome
from departamento d, (
			select cdep, AVG(salario) as media_salario
			from empregado
			group by cdep
			) tab1
where d.codigo = tab1.cdep and
tab1.media_salario = (
			select max(tab2.media_salario)
			from (	select d.codigo, tab1.media_salario
				from departamento d, (
							select cdep, AVG(salario) as media_salario
							from empregado
							group by cdep
							) tab1
				where d.codigo = tab1.cdep) tab2
			)

--**2. Recuperar para cada departamento: o seu nome, o maior e o menor salário recebido
--por empregados do departamento e a média salarial do departamento.

select d.dnome, tab1.max_salario, tab1.min_salario, tab2.media_salario
from departamento d, 
	(
	select tab_max.cdep, tab_max.max_salario, tab_min.min_salario
	from (
		select cdep, max(salario) as max_salario
		from empregado
		group by cdep
		) tab_max,
		(
		select cdep, min(salario) as min_salario
		from empregado
		group by cdep
		) tab_min
	where tab_max.cdep = tab_min.cdep
	) tab1,
	(
	select d.codigo, tab1.media_salario
	from departamento d, (
				select cdep, AVG(salario) as media_salario
				from empregado
				group by cdep
				) tab1
	where d.codigo = tab1.cdep
	) tab2
where tab1.cdep = tab2.codigo and d.codigo = tab1.cdep

--**3. Recuperar para cada departamento: o seu nome, o nome do seu gerente, a
--quantidade de empregados, a quantidade de projetos do departamento e a
--quantidade de unidades do departamento.

select d.dnome, tab1.enome, tab2.qtd_empregado, tab3.qtd_projeto, tab4.qtd_unidade
from departamento d,
	(
	select codigo, enome
	from departamento, empregado
	where cpf = gerente
	) tab1,
	(
	select cdep, count(cdep) as qtd_empregado
	from empregado
	group by cdep
	) tab2,
	(
	select cdep, count(cdep) as qtd_projeto
	from projeto
	group by cdep
	) tab3,
	(
	select dcodigo, count(dcodigo) as qtd_unidade
	from dunidade
	group by dcodigo
	) tab4
where d.codigo = tab1.codigo and d.codigo = tab2.cdep and
d.codigo = tab3.cdep and d.codigo = tab4.dcodigo
