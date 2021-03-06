﻿--Lista 13 - FBD
--Aluno: Geraldo Braz Duarte Filho
--Matrícula: 354063

--1. Recuperar o nome do departamento com maior média salarial.

select d.dnome
from departamento d, (
			select cdep, AVG(cast(salario as numeric)) as media_salario
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

--2. Recuperar para cada departamento: o seu nome, o maior e o menor salário recebido
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

--3. Recuperar para cada departamento: o seu nome, o nome do seu gerente, a
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

--4. Recuperar o nome do projeto que consome o maior número de horas.

select p.pnome
from projeto p, tarefa t
where p.pcodigo = t.pcodigo
group by p.pnome
having sum(t.horas) >= ALL( select sum(t.horas)as qtd_horas
from projeto p, tarefa t
where p.pcodigo = t.pcodigo
group by p.pnome)

--5. Recuperar o nome do projeto mais caro. (Corrigir: Fazer pelo cpf dado pra tarefa)

select p.pnome
from projeto p, empregado e
where p.cdep = e.cdep
group by p.pnome
having sum(e.salario) >= ALL( select sum(e.salario)
from projeto p, empregado e
where p.cdep = e.cdep
group by p.pnome
)

--6. Recuperar para cada projeto: o seu nome, o nome gerente do departamento que
--controla o projeto, a quantidade total de horas alocadas ao projeto, a quantidade de
--empregados alocados ao projeto e o custo mensal do projeto.

select p.pnome, e.enome, tab1.qtd_empregado, tab2.salario
from projeto p, empregado e, departamento d, 
	(
	select cdep, count(e.cdep) as qtd_empregado
	from empregado e
	group by cdep ) tab1,
	(
	select p.pnome, sum(e.salario) as salario
	from projeto p, empregado e
	where p.cdep = e.cdep
	group by p.pnome ) tab2
where p.cdep = d.codigo and d.gerente = e.cpf and tab1.cdep = d.codigo 
	and tab2.pnome = p.pnome
group by p.pnome, e.enome, tab1.qtd_empregado, tab2.salario

--7. Recuperar o nome dos gerentes com sobrenome ‘Silva’.

select e.enome
from empregado e, departamento d
where e.cpf = d.gerente and e.enome like '% Silva%'

--8. Recupere o nome dos gerentes que estão alocados em algum projeto (ou seja,
--possuem “alguma” tarefa em “algum” projeto).

select e.enome
from empregado e, 
	(
	select cpf
	from tarefa

	INTERSECT

	select gerente
	from departamento) tab1
where e.cpf = tab1.cpf

--9. Recuperar o nome dos empregados que participam de projetos que não são
--gerenciados pelo seu departamento.

select e.enome
from empregado e, 
	(
	select t.cpf, p.cdep
	from tarefa t, projeto p, 
		(
		select cpf, cdep
		from empregado) tab1
	where t.pcodigo = p.pcodigo and tab1.cpf = t.cpf and tab1.cdep <> p.cdep) tab2
where e.cpf = tab2.cpf

--10. Recuperar o nome dos empregados que participam de todos os projetos.

select e.enome
from empregado e, 
	(
	select distinct cpf, pcodigo
	from tarefa
	group by cpf, pcodigo
	having pcodigo = ALL (select pcodigo
				from projeto
				)
	) tab1
where e.cpf = tab1.cpf

--11. Recuperar para cada funcionário (empregado): o seu nome, o seu salário e o nome
--do seu departamento. O resultado deve estar em ordem decrescente de salário.
--Mostrar os empregados sem departamento e os departamentos sem empregados.

select enome, salario, dnome as departamento
from empregado
full outer join departamento
on empregado.cdep = departamento.codigo
order by salario desc

--12. Recuperar para cada funcionário (empregado): o seu nome, o nome do seu chefe e
--o nome do gerente do seu departamento.

select e.enome as funcionario, tab1.enome as chefe, tab2.enome as gerente
from empregado e,
	(
	select enome, cpf
	from empregado) tab1,
	(
	select e.enome, d.codigo
	from empregado e, departamento d
	where e.cpf = d.gerente) tab2
where e.chefe = tab1.cpf and e.cdep = tab2.codigo

--13. Listar nome dos departamentos com média salarial maior que a média salarial da
--empresa.

select dnome
from departamento, 
	(
	select cdep
	from empregado
	group by cdep
	having avg(cast(salario as numeric)) >= (
						select avg(cast(salario as numeric))
						from empregado )
	) tab1
where codigo = tab1.cdep

--14. Listar todos os empregados que possuem salário maior que a média salarial de
--seus departamentos.

select e.enome, e.cpf, e.endereco, e.nasc, e.sexo, e.salario, e.chefe, e.cdep
from empregado e,
	(
	select cdep, avg(cast(salario as numeric)) as med_salario
	from empregado
	group by cdep ) tab1
where e.cdep = tab1.cdep and cast(e.salario as numeric) >= cast(tab1.med_salario as numeric)

--15. Listar os empregados lotados nos departamentos localizados em “Fortaleza”.

select e.enome
from empregado e, departamento d, dunidade u
where e.cdep = d.codigo and d.codigo = u.dcodigo and u.dcidade = 'Fortaleza'

--16. Listar nome de departamentos com empregados ganhando duas vezes mais que a
--média do departamento.

select dnome 
from departamento,
	(
	select e.cdep
	from empregado e,
		(
		select cdep, avg(cast(salario as numeric)) as med_salario
		from empregado
		group by cdep ) tab1
	where e.cdep = tab1.cdep and cast(e.salario as numeric) >= 2*cast(tab1.med_salario as numeric) ) tab1
where codigo = tab1.cdep

--17. Recuperar o nome dos empregados com salário entre R$ 700 e R$ 2800.

select enome
from empregado
group by enome, salario
having cast(salario as numeric) between 700 and 2800

--18. Recuperar o nome dos departamentos que controlam projetos com mais de 50
--empregados e que também controlam projetos com menos de 5 empregados.

select d.dnome
from departamento d,
	(
	select p.cdep, sum(tab1.qtd_empregado) as qtd_empregado
	from projeto p, 
		(	
		select pcodigo, count(cpf) qtd_empregado
		from tarefa
		group by pcodigo ) tab1
	where p.pcodigo = tab1.pcodigo
	group by p.cdep ) tab2
where d.codigo = tab2.cdep
group by d.dnome, tab2.qtd_empregado
having tab2.qtd_empregado <= 5 or tab2.qtd_empregado >=50
