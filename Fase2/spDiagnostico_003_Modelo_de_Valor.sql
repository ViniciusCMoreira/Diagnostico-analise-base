USE [ateen]
GO

/****** Object:  StoredProcedure [dbo].[spDiagnostico_003_Modelo_de_Valor]    Script Date: 21/07/2014 14:32:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[spDiagnostico_003_Modelo_de_Valor]
AS
-----------------------------------------------------------------------------
-- objetivo		: montar a base de diagnóstico de modelo de valor 
-- data criação	: 26/02/2014
-- autor		: Tecnotime Consulting
-----------------------------------------------------------------------------
BEGIN

declare @ano int
select  @ano = 2013

-- Apagar todas as marcações de faixa (retenção)
update	temp_diag_fase1_perf_clie
set		faixa1ano = null,
		faixa2ano = null,
		faixa3ano = null
from	temp_diag_fase1_perf_clie a

set nocount off

--update a set subsegmento = null from temp_diag_fase1_perf_clie a where subsegmento = 'New buyer'      --and segmento = 'Ativo'
--update a set subsegmento = null from temp_diag_fase1_perf_clie a where subsegmento = 'One time buyer' --and segmento = 'Ativo'

begin
	-- Dropar a tabela temporária caso ela exista
	IF OBJECT_ID (N'dbo.temp', N'U') IS NOT NULL
		DROP TABLE dbo.temp

	-- Criar a tabela temporária
	create table [dbo].[temp](
		[cliente_id] [varchar](250) not null,
		[valor_faturado] [decimal](18, 2) null,
		[qtd_atendimento] [int] null,
		[segmento_valor] [int] null,
	primary key clustered 
	(
		[cliente_id] asc
	)with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [primary]
	) on [primary]

	-- conceitos para a baase Monte Carlo
	-- NEW BUYERS:	clientes que fizeram a sua primeira e única compra no ano ativo (não possuem compras em anos anteriores), 
	--				com recência menor que 6 meses. 
	-- ONE TIME BUYERS: clientes que fizeram a sua primeira e única compra no ano ativo (não possuem compras em anos anteriores), 
	--					com recência maior que 6 meses. 


	-- Preencher marcando o segmento dos clientes, no caso monte carlo usamos o faturamento dos dois ultimos anos
	insert	into temp
--	select	cliente_id, sum(isnull(b.faturamento1ano,0) + isnull(b.faturamento2ano,0)) as Faturamento1ano, null
	select	cliente_id, 
			sum(isnull(b.faturamento1ano,0))  as valor_faturado, 
			sum(isnull(b.atendimentos1ano,0)) as qtd_atendimento, 
			null
	from	temp_diag_fase1_perf_clie b
	inner join clientes a on cliente_id = clie_id
	where	isnull(CLIE_REGRA_OURO,'') = ''
			-- NÃO PODE SER NEW BUYER
--			and clie_id not in (select clie_id from clientes where (clie_freq_total = 1 and clie_dt_pri_compra between (select dateadd(month, -12, para_ult_venda)+1 from parametros) and (select para_ult_venda from parametros)))
			and subsegmento is null
	
			-- NÃO PODE SER ONE TIME BUYER
--			and clie_id not in (select clie_id from clientes where (clie_freq_total = 1 and clie_dt_pri_compra between (select dateadd(month, -24, para_ult_venda)+1 from parametros) and (select dateadd(month,-12,para_ult_venda) from parametros)))

			-- COM COMPRAS NOS ÚLTIMOS 12 MESES
			and clie_dt_ult_compra >= (select dateadd(month, -12, para_ult_venda)+1 from parametros)

			and clie_dt_ult_compra <= (select para_ult_venda from parametros)

    group	by cliente_id
	order	by 2 desc
end

exec SP_CALCULA_SEGMENTO_VALOR_FATURADO 9


end









GO

