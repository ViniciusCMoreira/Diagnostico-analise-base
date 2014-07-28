

/****** Object:  StoredProcedure [dbo].[spDiagnostico_002_Vendas]    Script Date: 21/07/2014 14:32:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




create PROCEDURE [dbo].[spDiagnostico_002_Vendas]
AS
-----------------------------------------------------------------------------
-- objetivo		: montar a base de diagnóstico de vendas 
-- data criação	: 26/02/2014
-- autor		: Tecnotime Consulting
-----------------------------------------------------------------------------

begin
	declare	@max_vend_dt datetime
	set		@max_vend_dt = (select max(vend_dt) from vendas)


	if exists(select * from sys.objects where name = N'temp_diag_fase1_perf_vend')
	drop table temp_diag_fase1_perf_vend

	create table temp_diag_fase1_perf_vend (
		cliente_cpf			varchar(250),
		venda_id			varchar(250),
		venda_data			datetime,
		loja_id				varchar(250),
		loja_nome			varchar(250),
		venda_dup			varchar(250),
		loja_id_null		varchar(250),
		vendedor_id_null	varchar(250),
		itens				varchar(10),
		valor_bruto			money,
		valor_final			money,
		cpf_valido			varchar(11),
		cpf_curinga			varchar(250),
		qtd_itens			int,
		ano_cadastro		int,
		venda_associada		varchar(11)
	)

	truncate table temp_diag_fase1_perf_vend
	
	insert	into temp_diag_fase1_perf_vend
	select	b.clie_cpf,
			a.vend_id,
			a.vend_dt,
			a.vend_loja_id,
			c.loja_nome,
			case when exists(select venda_id from _tmp_vendas group by venda_id having count(*) > 1) then 'S' else 'N' end as venda_dup,
			case when isnull(a.vend_loja_id,'') = '' then 'S' else 'N' end as loja_id_null,
			case when isnull(a.vend_veno_id,'') = '' then 'S' else 'N' end as vendedor_id_null,
			case when exists(select b.vend_id from itens_vendidos a, vendas b where a.iven_vend_id = b.vend_id) then 'S' else 'N' end as itens,
			convert(money, replace(vend_vlr_bruto, ',', '.')) as valor_bruto,
			convert(money, replace(vend_vlr_final, ',', '.')) as valor_bruto,
			dbo.fncvalidatecpf(b.clie_cpf) as cpf_valido,
			null,
		--	convert(int,replace(replace(vend_qt_pecas,',00',''),',10','')) as qtd,
		    null as qtd,
			year(b.clie_dt_cadastro) as ano_cadastro,
			case when isnull(a.vend_clie_id,'') <> '' then 'S' else 'N' end
	from	vendas a	left join clientes b on a.vend_clie_id = b.clie_id 
						left join lojas c on a.vend_loja_id = c.loja_id

	update	temp_diag_fase1_perf_vend 
	set		cpf_curinga = b.cpf_curinga
	from	temp_diag_fase1_perf_vend a inner join temp_diag_fase1_perf_clie b on a.cliente_cpf = b.cliente_cpf

	update	temp_diag_fase1_perf_vend
	set		venda_associada = 'N'
	from	temp_diag_fase1_perf_vend 
	where	isnull(cliente_cpf, '') = ''





	-- Apagar os subsegmentos
	update	temp_diag_fase1_perf_clie
	set		subsegmento = null

	-- Marcar os subsegmentos
	create table temp_subsegmento (
		subsegmento varchar(50),
		cliente_id	varchar(250),
		cliente_cpf varchar(250),
		faturamento money,
		qtd_itens	int)
		

	-- concetios para a baase Monte Carlo
	-- NEW BUYERS:	clientes que fizeram a sua primeira e única compra no ano ativo (não possuem compras em anos anteriores), 
	--				com recência menor que 6 meses. 
	-- ONE TIME BUYERS: clientes que fizeram a sua primeira e única compra no ano ativo (não possuem compras em anos anteriores), 
	--					com recência maior que 6 meses. 

	-- New buyers
	insert	into temp_subsegmento
	select	'New buyer' as segmento, c.clie_id, c.clie_cpf, sum(v.valor_bruto) as faturamento, sum(v.qtd_itens) as peças
	from	temp_diag_fase1_perf_clie d 
			inner join clientes c 
			on c.clie_id = d.cliente_id 
			inner join temp_diag_fase1_perf_vend  v on v.cliente_cpf = c.clie_cpf

	where	dt_venda_menor > dateadd(month, -6, @max_vend_dt)						-- Compraram nos últimos 6 meses
			and dt_venda_menor = dt_venda_maior										-- Só compraram uma vez
			and isnull(regra_ouro, '') = ''

	group	by c.clie_id, c.clie_cpf

	-- One timers
	insert	into temp_subsegmento
	select	'One time buyer' as segmento, c.clie_id, c.clie_cpf, sum(v.valor_bruto) as faturamento, sum(v.qtd_itens) as peças
	from	temp_diag_fase1_perf_clie d inner join clientes c on c.clie_id = d.cliente_id inner join temp_diag_fase1_perf_vend  v on v.cliente_cpf = c.clie_cpf
	where	dt_venda_menor	   >  dateadd(month, -12, @max_vend_dt)				-- Compraram no ano corrente e...
			and dt_venda_menor <= dateadd(month, -6, @max_vend_dt)				-- não compram há mais de 6 meses
			and dt_venda_menor = dt_venda_maior										-- Só compraram uma vez
			and isnull(regra_ouro, '') = ''
	group	by c.clie_id, c.clie_cpf

	-- Marcar os clientes de acordo com o subsegmento
	update	temp_diag_fase1_perf_clie
	set		subsegmento = null
	
	update	temp_diag_fase1_perf_clie
	set		subsegmento = b.subsegmento
	from	temp_diag_fase1_perf_clie as a inner join temp_subsegmento as b on a.cliente_id = b.cliente_id

	drop table temp_subsegmento

	
	
	
	-- Atualizar a quantidade de peças por clientes
	create table temp_pecas (
		cliente_id varchar(250),
		qtdpecas int
	)
	-- usando ano com 12 meses alterado da Monte Carlo que usa 24 meses
	insert	into temp_pecas
	select	cliente_cpf, sum(qtd_itens)
	from	temp_diag_fase1_perf_vend
	where	venda_data > dateadd(month, -12, @max_vend_dt)--2012-12-31 00:00:00.000
	group	by cliente_cpf



	update	temp_diag_fase1_perf_clie
	set		qtd_pecas = b.qtdpecas
	from	temp_diag_fase1_perf_clie as a inner join temp_pecas as b on a.cliente_cpf = b.cliente_id

	drop table temp_pecas
	
	-- Atualizar a associação de vendas
	update	temp_diag_fase1_perf_clie
	set		venda_associada = b.venda_associada
	from	temp_diag_fase1_perf_clie as a inner join temp_diag_fase1_perf_vend b on a.cliente_cpf = b.cliente_cpf
end









-- Ver a distribuição por segmento e subsegmento
/*
select	segmento, subsegmento, count(*)
from	temp_diag_fase1_perf_clie
group	by segmento, subsegmento
order	by segmento, subsegmento

select top 10 *
from temp_diag_fase1_perf_clie
where isnull(segmento, '') = 'Perdido'
*/

/*
begin
	-- Retenção
	create table temp_retencao (
		cliente_id varchar(250),
		fano1 int,
		fano2 int,
		fano3 int
	)

	insert	into temp_retencao
	select	c.cliente_id, 
			case	
					--when (isnull(c.faturamento1ano,0.00) + isnull(c.faturamento2ano,0.00)) <= 0			then null
					when (isnull(c.faturamento1ano,0.00) + isnull(c.faturamento2ano,0.00)) <= 840		then 9
					when (isnull(c.faturamento1ano,0.00) + isnull(c.faturamento2ano,0.00)) <= 1538		then 8
					when (isnull(c.faturamento1ano,0.00) + isnull(c.faturamento2ano,0.00)) <= 2312.03	then 7
					when (isnull(c.faturamento1ano,0.00) + isnull(c.faturamento2ano,0.00)) <= 3357		then 6
					when (isnull(c.faturamento1ano,0.00) + isnull(c.faturamento2ano,0.00)) <= 4974		then 5
					when (isnull(c.faturamento1ano,0.00) + isnull(c.faturamento2ano,0.00)) <= 7911.90	then 4
					when (isnull(c.faturamento1ano,0.00) + isnull(c.faturamento2ano,0.00)) <= 15150		then 3
					when (isnull(c.faturamento1ano,0.00) + isnull(c.faturamento2ano,0.00)) <= 39016		then 2
					else 1
			end,
			case	
					--when (isnull(c.faturamento3ano,0.00) + isnull(c.faturamento4ano,0.00)) <= 0			then null
					when (isnull(c.faturamento3ano,0.00) + isnull(c.faturamento4ano,0.00)) <= 840		then 9
					when (isnull(c.faturamento3ano,0.00) + isnull(c.faturamento4ano,0.00)) <= 1538		then 8
					when (isnull(c.faturamento3ano,0.00) + isnull(c.faturamento4ano,0.00)) <= 2312.03	then 7
					when (isnull(c.faturamento3ano,0.00) + isnull(c.faturamento4ano,0.00)) <= 3357			then 6
					when (isnull(c.faturamento3ano,0.00) + isnull(c.faturamento4ano,0.00)) <= 4974			then 5
					when (isnull(c.faturamento3ano,0.00) + isnull(c.faturamento4ano,0.00)) <= 7911.90	then 4
					when (isnull(c.faturamento3ano,0.00) + isnull(c.faturamento4ano,0.00)) <= 15150		then 3
					when (isnull(c.faturamento3ano,0.00) + isnull(c.faturamento4ano,0.00)) <= 39016		then 2
					else 1
			end,
			case	
					--when (isnull(c.faturamento5ano,0.00) + isnull(c.faturamento6ano,0.00)) <= 0			then null
					when (isnull(c.faturamento5ano,0.00) + isnull(c.faturamento6ano,0.00)) <= 840		then 9
					when (isnull(c.faturamento5ano,0.00) + isnull(c.faturamento6ano,0.00)) <= 1538		then 8
					when (isnull(c.faturamento5ano,0.00) + isnull(c.faturamento6ano,0.00)) <= 2312.03	then 7
					when (isnull(c.faturamento5ano,0.00) + isnull(c.faturamento6ano,0.00)) <= 3357		then 6
					when (isnull(c.faturamento5ano,0.00) + isnull(c.faturamento6ano,0.00)) <= 4974		then 5
					when (isnull(c.faturamento5ano,0.00) + isnull(c.faturamento6ano,0.00)) <= 7911.90	then 4
					when (isnull(c.faturamento5ano,0.00) + isnull(c.faturamento6ano,0.00)) <= 15150		then 3
					when (isnull(c.faturamento5ano,0.00) + isnull(c.faturamento6ano,0.00)) <= 39016		then 2
					else 1
			end

	from	temp_diag_fase1_perf_clie c

	-- Atualizar a fato de clientes
	update	temp_diag_fase1_perf_clie
	set		faixa1ano = b.fano1,
			faixa2ano = b.fano2,
			faixa3ano = b.fano3
	from	temp_diag_fase1_perf_clie a inner join temp_retencao b on a.cliente_id = b.cliente_id

	drop table temp_retencao
end
*/







GO

