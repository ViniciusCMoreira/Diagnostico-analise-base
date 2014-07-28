

/****** Object:  StoredProcedure [dbo].[spDiagnostico_001_Clientes]    Script Date: 21/07/2014 14:32:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


alter  PROCEDURE [dbo].[spDiagnostico_001_Clientes]
AS
-----------------------------------------------------------------------------
-- objetivo		: montar a base de diagnóstico de clientes 
-- data criação	: 26/02/2014
-- autor		: Tecnotime Consulting
-----------------------------------------------------------------------------

-- Montar a fato de clientes
begin
	set dateformat dmy
	-- Criar a tabela de diagnóstico de clientes
	if exists(select * from sys.objects where name = N'temp_diag_fase1_perf_clie')
		drop table temp_diag_fase1_perf_clie

	create	table temp_diag_fase1_perf_clie (
		cliente_id				varchar(250),				--
		cliente_cpf				varchar(250),				-- CPF do cliente
 		loja_id					varchar(250),				-- ID da loja
		loja_nome				varchar(250),				-- Nome da loja
		cliente_nome			varchar(1),					-- 
		cliente_sexo			varchar(1),					--
		cpf_valido				varchar(1),					--

		loja_id_null			varchar(1),					--
		idade_faixa				varchar(250),				--
		status_aniversario		varchar(250),				--
		data_nascimento			datetime,					--
		data_cadastro			datetime,					--
		ano_cadastro			int,						--
--		data_nascimento_conjuge	varchar(250),
--		data_casamento			varchar(250),

		status_ddd_cel			varchar(1),					--
		status_ddd_tel			varchar(1),					--

		status_email			varchar(1),					--
		cliente_uf				varchar(250),				--
		status_end				varchar(1),					--
		cliente_cidade			varchar(100),				--
		cliente_bairro			varchar(100),				--
		cpf_dup					varchar(1),					--
		cpf_curinga				varchar(1),					--

		loja_preferencial		varchar(100),				--
		loja_preferencial_nome	varchar(250),				--
		segmento				varchar (250),				--
		subsegmento				varchar(250),				--
		qtd_pecas				int,						--

		-- Comprou no 1º, 2º e 3º ano. 
		-- Sendo o 1º ano o ano mais recente, e o 3º o mais antigo
		comprou1ano				char(1),
		comprou2anos			char(1),
		comprou3anos			char(1),
		comprou4anos			char(1),
		comprou5anos			char(1),
		comprou6anos			char(1),

		-- Primeira e última data de venda
		dt_venda_menor			datetime,
		dt_venda_maior			datetime,

		-- Faturamento mensal no ano corrente
		faturamento01			money,					
		faturamento02			money,					
		faturamento03			money,
		faturamento04			money,
		faturamento05			money,
		faturamento06			money,
		faturamento07			money,
		faturamento08			money,
		faturamento09			money,
		faturamento10			money,
		faturamento11			money,
		faturamento12			money,
		faturamentototal		money,					-- Faturamento total deste cliente
		faturamento1ano			money,					-- Faturamento deste cliente no 1º ano
		faturamento2ano			money,					-- Faturamento deste cliente no 2º ano
		faturamento3ano			money,					-- Faturamento deste cliente no 3º ano
		faturamento4ano			money,					-- Faturamento deste cliente no 4º ano
		faturamento5ano			money,					-- Faturamento deste cliente no 5º ano
		faturamento6ano			money,					-- Faturamento deste cliente no 6º ano
		Faturamento1Ano_b2c		money,					-- Faturamento deste cliente no 1º ano E-Commerce

		-- Modelo de valor
		faixa1ano				int,
		faixa2ano				int,
		faixa3ano				int,

		--
		atendimentos01			int,
		atendimentos02			int, 
		atendimentos03			int,
		atendimentos04			int,
		atendimentos05			int,
		atendimentos06			int,
		atendimentos07			int,
		atendimentos08			int,
		atendimentos09			int,
		atendimentos10			int,
		atendimentos11			int,
		atendimentos12			int,
		atendimentostotal		int,
		atendimentos1ano		int,
		atendimentos2ano		int,
		atendimentos3ano		int,
		atendimentos4ano		int,
		atendimentos5ano		int,
		atendimentos6ano		int,
		atendimentos1ano_b2c	int,		

		qtd_meses_1ano			int,
		qtd_meses_2ano			int,
		qtd_meses_3ano			int,
		qtd_meses_4ano			int,
		qtd_meses_5ano			int,
		qtd_meses_6ano			int,

		venda_associada			char(1),
		funcionario				char(1),
		tem_midia				char(1),
		cluster_programa		int,
		produto_linha			varchar(250),
		produto_grupo_b2c		varchar(250),
		produto_nome			varchar(250),

		produto_mais_comprado_compra1	varchar(250),
		produto_mais_comprado_12meses	varchar(250),
		produto_mais_comprado_12meses_b2c	varchar(250),



		produto_faixa			varchar(50),
		produto_faixa_b2c		varchar(50),
		regra_ouro				varchar(50),
		segmento_base			varchar(50),
		clie_status				char(1),
		clie_ativo				char(1),
		
		seg2010					int,
		seg2011					int,
		seg2012					int,
		seg2013					int,
		
		rfv2010					char(3),
		rfv2011					char(3),
		rfv2012					char(3),
		rfv2013					char(3),	
		desempenho				varchar(25),				-- (Retidos, Novos e Resgatados)
		LOJA_PRI_COMPRA			varchar(100),
		Qtd_pecas_b2c			int,
		-- PRimeira venda / Segunda venda / Recência e Frequencia 
	   dt_primeira_compra				datetime,
	   val_primeira_compra				money,
	   dt_segunda_compra				datetime,
	   val_segunda_compra				money ,
	   qtd_dias_pos_primeira_compra		int,
	   qtd_atend_pos_primeira_compra	int,
	   qtd_mes_pos_primeira_compra		varchar(10)

		)

	truncate table temp_diag_fase1_perf_clie
	
	-- Tempo: 02:10
	insert	into temp_diag_fase1_perf_clie
	select	a.clie_id															cliente_id				, 
			a.clie_cpf															cliente_cpf				, 
			a.clie_loja_id														loja_id					, 
			b.loja_nome															loja_nome				,
			case when isnull(clie_nome, '') = '' then 'N' else 'S'			end	cliente_nome			,
			case when isnull(clie_sexo, '') = '' then 'N' else clie_sexo	end	cliente_sexo			,
			dbo.fncValidateCPF(clie_cpf)										cpf_valido				,
			case	when isnull(a.clie_loja_id, '') = '' then 'N' else 'S'	end	loja_id_null			,
			dbo.FN_FX_ETARIA (a.clie_dt_nasc)									idade_faixa				,
			case	when isnull(a.clie_dt_nasc, '') <> '' then 'S' else 'N' end	status_aniversario		,
			a.clie_dt_nasc														data_nascimento			,
			a.clie_dt_cadastro													data_cadastro			,
			year(a.clie_dt_cadastro)											ano_cadastro			,

--			clie_dt_nasc_conjuge												data_nascimento_conjuge	,
--			clie_dt_casamento													data_casamento			,

			case	when ([dbo].fncValidateCel(clie_cel) = 'S' and ltrim(rtrim(clie_cel_ddd)) between '11' and '99') then 'S' else 'N' end	status_ddd_cel,
			case	when ([dbo].fncValidateTel(clie_tel) = 'S' and ltrim(rtrim(clie_tel_ddd)) between '11' and '99') then 'S' else 'N' end	status_ddd_tel,
			[dbo].fncValidateEmail('animale', clie_email)					status_email			,
			case	when isnull(clie_uf, '') = '' then 'NÃO PREENCHIDO' else clie_uf end	cliente_uf	,
			--case	when ltrim(rtrim(replace(replace(replace(replace((ltrim(rtrim(isnull(clie_tipo_log, ''))) + ' ' + ltrim(rtrim(isnull(clie_logradouro, ''))) + ' ' + ltrim(rtrim(isnull(clie_numero, ''))) + ' ' + ltrim(rtrim(isnull(clie_complemento, '')))),'  ',' ') ,'  ',' '),'  ',' '),'  ',' '))) <> '' and ltrim(rtrim(isnull(clie_cidade, ''))) <> '' and ltrim(rtrim(isnull(clie_uf, ''))) <> '' and LEN(ltrim(rtrim(isnull(clie_cep, '')))) = 8 then 'S' else 'N' end	,
			CASE WHEN	LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE((LTRIM(RTRIM(ISNULL(CLIE_TIPO_LOG,''))) + ' ' + LTRIM(RTRIM(ISNULL(CLIE_LOGRADOURO,''))) + ' ' + LTRIM(RTRIM(ISNULL(CLIE_NUMERO,''))) + ' ' + LTRIM(RTRIM(ISNULL(CLIE_COMPLEMENTO,'')))),'  ',' '),'  ',' '),'  ',' '),'  ',' '))) <> '' AND
												LTRIM(RTRIM(ISNULL(CLIE_CIDA_ID,''))) <> '' AND
												LTRIM(RTRIM(ISNULL(CLIE_UF,''))) <> '' AND
												LEN(LTRIM(RTRIM(ISNULL(CLIE_CEP,'')))) = 8 THEN 'S' ELSE 'N' END stat_end,
			clie_cidade															cliente_cidade			,
			clie_bairro															cliente_bairro			,
			'N'																	cpf_dup					,
			case	when clie_cpf = '99999999999' then 'S' else 'N' end			cpf_curinga				,
			null																loja_preferencial		,
			null																loja_preferencial_nome	,
			null																segmento				,
			null																subsegmento				,
			null																qtd_pecas				,
			null																comprou1ano				,
			null																comprou2anos			,
			null																comprou3anos			,
			null																comprou4anos			,
			null																comprou5anos			,
			null																comprou6anos			,
			null																dt_venda_menor			,
			null																dt_venda_maior			,
			null																faturamento01			,	
			null																faturamento02			,	
			null																faturamento03			,	
			null																faturamento04			,	
			null																faturamento05			,	
			null																faturamento06			,	
			null																faturamento07			,	
			null																faturamento08			,	
			null																faturamento09			,	
			null																faturamento10			,	
			null																faturamento11			,	
			null																faturamento12			,	
			null																faturamentototal		,	
			null																faturamento1ano			,	
			null																faturamento2ano			,	
			null																faturamento3ano			,	
			null																faturamento4ano			,	
			null																faturamento5ano			,	
			null																faturamento6ano			,	
			null																Faturamento1Ano_b2c		,
			null																faixa1ano				, 
			null																faixa2ano				,
			null																faixa3ano				,
			null																atendimentos01			,		
			null																atendimentos02			,		
			null																atendimentos03			,		
			null																atendimentos04			,		
			null																atendimentos05			,		
			null																atendimentos06			,		
			null																atendimentos07			,		
			null																atendimentos08			,		
			null																atendimentos09			,		
			null																atendimentos10			,		
			null																atendimentos11			,		
			null																atendimentos12			,		
			null																atendimentostotal		,	
			null																atendimentos1ano		,	
			null																atendimentos2ano		,	
			null																atendimentos3ano		,	
			null																atendimentos4ano		,	
			null																atendimentos5ano		,	
			null																atendimentos6ano		,
			null																atendimentos1ano_b2c	,
			null																qtd_meses_1ano			,		
			null																qtd_meses_2ano			,		
			null																qtd_meses_3ano			,		
			null																qtd_meses_4ano			,		
			null																qtd_meses_5ano			,		
			null																qtd_meses_6ano			,		
			null																venda_associada			,
			case	when (select 1 from funcionarios c where c.FUNC_CPF = a.CLIE_CPF) = 1 then 'S' else 'N' end	funcionario				,	
			'N'																	tem_midia				,
			CLIE_CLUS_ID														cluster_programa		,
			null																produto_linha			,
			null																produto_grupo_b2c		,
			null																produto_nome			,
			null																produto_mais_comprado_compra1,
			null																produto_mais_comprado_12meses,
			null																produto_mais_comprado_12meses_b2c,
			null																produto_faixa			,
			null																produto_faixa_b2c		,
			clie_regra_ouro														regra_ouro				,
			(select clus_nome from clusters where clus_id = clie_clus_id)		segmento_base			,
			clie_status															clie_status				,
			clie_ativo															clie_ativo				,
			null																seg2010					,
			null																seg2011					,
			null																seg2012					,
			null																seg2013					,
			null																rfv2010					,
			null																rfv2011					,
			null																rfv2012					,
			null																rfv2013					,
			null																desempenho				,
			null																pri_compra				,
			null																Qtd_pecas_b2c			,
			null		dt_primeira_compra,			
			null		val_primeira_compra,			
			null		dt_segunda_compra	,		
			null		val_segunda_compra	,		
			null		qtd_dias_pos_primeira_compra	,
			null		qtd_atend_pos_primeira_compra,
			null		qtd_mes_pos_primeira_compra	
	from	clientes a left join lojas b on a.clie_loja_id = b.loja_id
	order	by a.clie_cpf		-- o order by ajuda na depuração pois garante que todos os INSERTs serão feitos na mesma ordem sempre

	-- Atualizar tem_midia [00:03]
	update	temp_diag_fase1_perf_clie 
	set		tem_midia = 'S'
	where	status_ddd_cel = 'S'
			or status_ddd_tel = 'S'
			or status_email = 'S'
			or status_end = 'S'

	-- Acerto de Bairros [00:01]
	update	temp_diag_fase1_perf_clie 
	set		cliente_bairro = tb2.lkba_to 
	from	temp_diag_fase1_perf_clie as tb1 inner join i9.dbo.lookup_bairros as tb2 on tb1.cliente_bairro = tb2.lkba_from
	where	isnull(cliente_bairro, '') <> ''

	-- Bairros que não tem qualidade de preenchimento entram como null [00:11]
	update	temp_diag_fase1_perf_clie 
	set		cliente_bairro = null
	from	temp_diag_fase1_perf_clie a 
	where	not exists (select 1 from i9.dbo.lookup_bairros b where a.cliente_bairro = b.lkba_from)

	update	temp_diag_fase1_perf_clie 
	set		cliente_cidade = tb2.lkci_to 
	from	temp_diag_fase1_perf_clie as tb1 inner join i9.dbo.lookup_cidades as tb2 on tb1.cliente_cidade = tb2.lkci_from
	where	isnull(cliente_cidade, '') <> ''

	update	temp_diag_fase1_perf_clie 
	set		cliente_cidade = null
	from	temp_diag_fase1_perf_clie a 
	where	not exists (select 1 from i9.dbo.lookup_cidades b where a.cliente_cidade = b.lkci_from)

	update	temp_diag_fase1_perf_clie 
	set		loja_preferencial		= a.loja_id,
			loja_preferencial_nome	= l.loja_nome
	from	temp_diag_fase1_perf_clie a 
	inner join lojas l
	on	a.loja_id COLLATE DATABASE_DEFAULT = l.loja_id COLLATE DATABASE_DEFAULT
	where	isnull(loja_preferencial, '') = ''


	-- Determinar CPFs duplos [00:01]
	update	temp_diag_fase1_perf_clie 
	set		cpf_dup = 'S'
	where	cliente_cpf in (select a.clie_cpf from clientes a 
							join temp_diag_fase1_perf_clie b 
							on a.clie_cpf = b.cliente_cpf 
							group	by a.clie_cpf 
							having count(*) > 1)

	-- Determinar CPFs únicos [00:06]
	update	temp_diag_fase1_perf_clie
	set		cpf_dup = 'N'
	from	temp_diag_fase1_perf_clie a, clientes b
	where	a.cpf_dup = 'S'
			and a.cliente_cpf = b.clie_cpf
			and a.cliente_id = (select max(c.clie_id) from clientes c where a.cliente_cpf = c.clie_cpf)

end



-- Fazer os cálculos em cima da fato de clientes [03:42]
begin
	DECLARE	@max_vend_dt datetime

	SET @max_vend_dt = CONVERT(char(8),(select max(vend_dt) from vendas),112)

	-- Calcular o valor acumulado por cliente, loja e data
	if object_id('tempdb..##temp2','u') is not null
		drop table ##temp2

	create	table ##temp2 (
		cliente_id		varchar(100),
		loja_id			varchar(100),
		venda_data		datetime,
		vlr_acumulado	money )

	insert	into ##temp2 (cliente_id, loja_id, venda_data, vlr_acumulado)
	select	vend_clie_id, vend_loja_id, vend_dt,
			sum(vend_vlr_final) as vlr_acumulado
	from	vendas
	where	isnull(vend_clie_id, '') <> ''
	group	by vend_clie_id, vend_loja_id, vend_dt


	-- Determinar a loja de preferência dos clientes
	-- (é a loja onde ele mais comprou nos últimos 12 meses) no caso da monte carlo usamos 24 meses
	-- @@@ como conferir?
	if object_id('tempdb..##temp3','u') is not null
		drop table ##temp3

	create	table ##temp3 (
		cliente_id	varchar(100),
		loja_id		varchar(100),
	)

	insert	into ##temp3 (cliente_id, loja_id)
	select	cliente_id, loja_id
	from	##temp2
	where	venda_data between dateadd(month, -12, @max_vend_dt) and @max_vend_dt
	group	by cliente_id, loja_id
	having	max(vlr_acumulado) = max(vlr_acumulado)

	
	update	temp_diag_fase1_perf_clie 
	set		loja_preferencial		= tb3.loja_id,
			loja_preferencial_nome	= l.loja_nome

	from	temp_diag_fase1_perf_clie as tb1 
	
	inner join ##temp3 as tb3 
	on tb1.cliente_id COLLATE DATABASE_DEFAULT = tb3.cliente_id COLLATE DATABASE_DEFAULT

	inner join lojas l
	on	tb3.loja_id COLLATE DATABASE_DEFAULT = l.loja_id COLLATE DATABASE_DEFAULT


	-- Calcular o valor acumulado por cliente, produto e data
	if object_id('tempdb..##temp_acum_produto_detalhe','u') is not null
		drop table ##temp_acum_produto_detalhe

	create	table ##temp_acum_produto_detalhe (
		cliente_id		varchar(100),
		prod_id			varchar(250),
		venda_data		datetime,
		iven_qtd		int,
		vlr_acumulado	money )

	insert	into ##temp_acum_produto_detalhe (cliente_id, prod_id, venda_data, iven_qtd, vlr_acumulado)
	select	vend_clie_id, iven_prod_id, vend_dt, 
			sum(iven_qtd)		iven_qtd,
			sum(vend_vlr_final) vlr_acumulado
	from	vendas v

	inner	join ITENS_VENDIDOS i
	on		v.vend_id COLLATE DATABASE_DEFAULT = i.iven_vend_id COLLATE DATABASE_DEFAULT

	where	isnull(vend_clie_id, '') <> ''
	group	by vend_clie_id, iven_prod_id, vend_dt


	-- Calcular o valor acumulado por cliente, produto e data
	if object_id('tempdb..##temp_acum_produto','u') is not null
		drop table ##temp_acum_produto

	create	table ##temp_acum_produto (
		cliente_id		varchar(100),
		prod_id			varchar(250),
		vlr_acumulado	money )

	insert	into ##temp_acum_produto (cliente_id, prod_id, vlr_acumulado)

	select	cliente_id, prod_id, max(vlr_acumulado)
	from	##temp_acum_produto_detalhe
	where	venda_data between dateadd(month, -12, @max_vend_dt) and @max_vend_dt
	group	by cliente_id, prod_id
	having	max(vlr_acumulado) = max(vlr_acumulado)


	update	temp_diag_fase1_perf_clie 
	set		produto_mais_comprado_12meses	= prod_nome
	from	temp_diag_fase1_perf_clie as t 
	
	inner join ##temp_acum_produto as t2 
	on	t.cliente_id COLLATE DATABASE_DEFAULT = t2.cliente_id COLLATE DATABASE_DEFAULT

	inner join produtos p
	on	p.prod_id COLLATE DATABASE_DEFAULT = t2.prod_id COLLATE DATABASE_DEFAULT


	
	-- Determinar o faturamento e o atendimento por faixas



	if object_id('tempdb..##temp5','u') is not null
		drop table ##temp5

	create table ##temp5 (
			cliente_id varchar(100),
			regra_ouro varchar(250),
			
			comprou1ano  char(1),			-- Comprou no 1o ano
			comprou2anos char(1),			-- Comprou no 2o ano
			comprou3anos char(1),			-- Comprou no 3o ano
			comprou4anos char(1),			-- Comprou no 3o ano
			comprou5anos char(1),			-- Comprou no 3o ano
			comprou6anos char(1),			-- Comprou no 3o ano

			dt_venda_menor datetime,
			dt_venda_maior datetime,

			faturamento01 money,
			faturamento02 money,
			faturamento03 money,
			faturamento04 money,
			faturamento05 money,
			faturamento06 money,
			faturamento07 money,
			faturamento08 money,
			faturamento09 money,
			faturamento10 money,
			faturamento11 money,
			faturamento12 money,
			faturamentototal money,
			faturamento1ano money,
			faturamento2ano money,
			faturamento3ano money,
			faturamento4ano money,
			faturamento5ano money,
			faturamento6ano money,
			Faturamento1Ano_b2c money,

			atendimentos01 int,
			atendimentos02 int, 
			atendimentos03 int,
			atendimentos04 int,
			atendimentos05 int,
			atendimentos06 int,
			atendimentos07 int,
			atendimentos08 int,
			atendimentos09 int,
			atendimentos10 int,
			atendimentos11 int,
			atendimentos12 int,
			atendimentostotal int,
			atendimentos1ano int,
			atendimentos2ano int,
			atendimentos3ano int,
			atendimentos4ano int,
			atendimentos5ano int,
			atendimentos6ano int,
			atendimentos1ano_b2c int,			

			qtd_meses_1ano int,
			qtd_meses_2ano int,
			qtd_meses_3ano int,
			qtd_meses_4ano int,
			qtd_meses_5ano int,
			qtd_meses_6ano int
	)

	insert	into ##temp5
	select	distinct 
			a.clie_id
			, a.clie_regra_ouro,
			-- Comprou x ano
			case when exists (select 1 from vendas b where a.clie_id = b.vend_clie_id and b.vend_dt >  dateadd(month, -12, @max_vend_dt) and b.vend_dt <= @max_vend_dt) then 'S' else 'N' end						as 'comprou1ano',
			case when exists (select 1 from vendas b where a.clie_id = b.vend_clie_id and b.vend_dt >  dateadd(month, -24, @max_vend_dt) and b.vend_dt <= dateadd(month, -12, @max_vend_dt)) then 'S' else 'N' end	as 'comprou2ano',
			case when exists (select 1 from vendas b where a.clie_id = b.vend_clie_id and b.vend_dt >  dateadd(month, -36, @max_vend_dt) and b.vend_dt <= dateadd(month, -24, @max_vend_dt)) then 'S' else 'N' end	as 'comprou3ano',
			case when exists (select 1 from vendas b where a.clie_id = b.vend_clie_id and b.vend_dt >  dateadd(month, -48, @max_vend_dt) and b.vend_dt <= dateadd(month, -36, @max_vend_dt)) then 'S' else 'N' end	as 'comprou4ano',
			case when exists (select 1 from vendas b where a.clie_id = b.vend_clie_id and b.vend_dt >  dateadd(month, -60, @max_vend_dt) and b.vend_dt <= dateadd(month, -48, @max_vend_dt)) then 'S' else 'N' end	as 'comprou5ano',
			case when exists (select 1 from vendas b where a.clie_id = b.vend_clie_id and b.vend_dt <= dateadd(month, -60, @max_vend_dt))													 then 'S' else 'N' end	as 'comprou6ano',

			-- Primeira e última venda
			(select min(vend_dt) from vendas b where a.clie_id = b.vend_clie_id) as 'dt_venda_menor',
			(select max(vend_dt) from vendas b where a.clie_id = b.vend_clie_id) as 'dt_venda_maior',

			-- Faturamentos
			(select sum(b.vend_vlr_final) from VENDAS b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -1, @max_vend_dt) and b.vend_dt <= @max_vend_dt)							as 'Faturamento12',
			(select sum(b.vend_vlr_final) from VENDAS b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -2, @max_vend_dt) and b.vend_dt <= dateadd(month, -1, @max_vend_dt))		as 'Faturamento11',
			(select sum(b.vend_vlr_final) from VENDAS b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -3, @max_vend_dt) and b.vend_dt <= dateadd(month, -2, @max_vend_dt))		as 'Faturamento10',
			(select sum(b.vend_vlr_final) from VENDAS b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -4, @max_vend_dt) and b.vend_dt <= dateadd(month, -3, @max_vend_dt))		as 'Faturamento09',
			(select sum(b.vend_vlr_final) from VENDAS b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -5, @max_vend_dt) and b.vend_dt <= dateadd(month, -4, @max_vend_dt))		as 'Faturamento08',
			(select sum(b.vend_vlr_final) from VENDAS b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -6, @max_vend_dt) and b.vend_dt <= dateadd(month, -5, @max_vend_dt))		as 'Faturamento07',
			(select sum(b.vend_vlr_final) from VENDAS b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -7, @max_vend_dt) and b.vend_dt <= dateadd(month, -6, @max_vend_dt))		as 'Faturamento06',
			(select sum(b.vend_vlr_final) from VENDAS b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -8, @max_vend_dt) and b.vend_dt <= dateadd(month, -7, @max_vend_dt))		as 'Faturamento05',
			(select sum(b.vend_vlr_final) from VENDAS b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -9, @max_vend_dt) and b.vend_dt <= dateadd(month, -8, @max_vend_dt))		as 'Faturamento04',
			(select sum(b.vend_vlr_final) from VENDAS b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -10, @max_vend_dt) and b.vend_dt <= dateadd(month, -9, @max_vend_dt))		as 'Faturamento03',
			(select sum(b.vend_vlr_final) from VENDAS b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -11, @max_vend_dt) and b.vend_dt <= dateadd(month, -10, @max_vend_dt))		as 'Faturamento02',
			(select sum(b.vend_vlr_final) from VENDAS b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -12, @max_vend_dt) and b.vend_dt <= dateadd(month, -11, @max_vend_dt))		as 'Faturamento01',
			(select sum(b.vend_vlr_final) from VENDAS b where b.vend_clie_id = a.clie_id)																											as 'FaturamentoTotal',
			(select sum(b.vend_vlr_final) from VENDAS b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -12, @max_vend_dt) and b.vend_dt <= @max_vend_dt)							as 'Faturamento1Ano',
			(select sum(b.vend_vlr_final) from VENDAS b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -24, @max_vend_dt) and b.vend_dt <= dateadd(month, -12, @max_vend_dt))		as 'Faturamento2Ano',
			(select sum(b.vend_vlr_final) from VENDAS b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -36, @max_vend_dt) and b.vend_dt <= dateadd(month, -24, @max_vend_dt))		as 'Faturamento3Ano',
			(select sum(b.vend_vlr_final) from VENDAS b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -48, @max_vend_dt) and b.vend_dt <= dateadd(month, -36, @max_vend_dt))		as 'Faturamento4Ano',
			(select sum(b.vend_vlr_final) from VENDAS b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -60, @max_vend_dt) and b.vend_dt <= dateadd(month, -48, @max_vend_dt))		as 'Faturamento5Ano',
			(select sum(b.vend_vlr_final) from VENDAS b where b.vend_clie_id = a.clie_id and b.vend_dt <= dateadd(month,-60, @max_vend_dt))															as 'Faturamento6Ano',
			(select sum(b.vend_vlr_final) from VENDAS b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -12, @max_vend_dt) and b.vend_dt <= @max_vend_dt AND VEND_LOJA_ID = '000042') as 'Faturamento1Ano_b2c',
		
			-- Atendimentos
			(select count(*) from vendas b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -1, @max_vend_dt) and b.vend_dt <= @max_vend_dt)							as 'Atendimentos12',
			(select count(*) from vendas b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -2, @max_vend_dt) and b.vend_dt <= dateadd(month, -1, @max_vend_dt))		as 'Atendimentos11',
			(select count(*) from vendas b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -3, @max_vend_dt) and b.vend_dt <= dateadd(month, -2, @max_vend_dt))		as 'Atendimentos10',
			(select count(*) from vendas b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -4, @max_vend_dt) and b.vend_dt <= dateadd(month, -3, @max_vend_dt))		as 'Atendimentos09',
			(select count(*) from vendas b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -5, @max_vend_dt) and b.vend_dt <= dateadd(month, -4, @max_vend_dt))		as 'Atendimentos08',
			(select count(*) from vendas b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -6, @max_vend_dt) and b.vend_dt <= dateadd(month, -5, @max_vend_dt))		as 'Atendimentos07',
			(select count(*) from vendas b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -7, @max_vend_dt) and b.vend_dt <= dateadd(month, -6, @max_vend_dt))		as 'Atendimentos06',
			(select count(*) from vendas b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -8, @max_vend_dt) and b.vend_dt <= dateadd(month, -7, @max_vend_dt))		as 'Atendimentos05',
			(select count(*) from vendas b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -9, @max_vend_dt) and b.vend_dt <= dateadd(month, -8, @max_vend_dt))		as 'Atendimentos04',
			(select count(*) from vendas b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -10, @max_vend_dt) and b.vend_dt <= dateadd(month, -9, @max_vend_dt))	as 'Atendimentos03',
			(select count(*) from vendas b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -11, @max_vend_dt) and b.vend_dt <= dateadd(month, -10, @max_vend_dt))	as 'Atendimentos02',
			(select count(*) from vendas b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -12, @max_vend_dt) and b.vend_dt <= dateadd(month, -11, @max_vend_dt))	as 'Atendimentos01',
			(select count(*) from vendas b where b.vend_clie_id = a.clie_id)																										as 'AtendimentosTotal',
			(select count(*) from vendas b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -12, @max_vend_dt) and b.vend_dt <= @max_vend_dt)						as 'Atendimentos1ano',
			(select count(*) from vendas b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -24, @max_vend_dt) and b.vend_dt <= dateadd(month, -12, @max_vend_dt))	as 'Atendimentos2ano',
			(select count(*) from vendas b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -36, @max_vend_dt) and b.vend_dt <= dateadd(month, -24, @max_vend_dt))	as 'Atendimentos3ano',
			(select count(*) from vendas b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -48, @max_vend_dt) and b.vend_dt <= dateadd(month, -36, @max_vend_dt))	as 'Atendimentos4ano',
			(select count(*) from vendas b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -60, @max_vend_dt) and b.vend_dt <= dateadd(month, -48, @max_vend_dt))	as 'Atendimentos5ano',
			(select count(*) from vendas b where b.vend_clie_id = a.clie_id and b.vend_dt <= dateadd(month,-60, @max_vend_dt))														as 'Atendimentos6ano',

			(select count(*) from vendas b where b.vend_clie_id = a.clie_id and b.vend_dt > dateadd(month, -12, @max_vend_dt) and b.vend_dt <= @max_vend_dt and vend_loja_id = '000042')						as 'Atendimentos1ano_b2c',
			

			ISNULL((SELECT COUNT(DISTINCT(left(CONVERT(char(8),vend_dt,112),6))) FROM VENDAS b where b.vend_clie_id = a.clie_id and b.vend_dt between DATEADD(YEAR,-1,@max_vend_dt)+1 and @max_vend_dt ),0)	as 'qtd_meses_1ano',
			ISNULL((SELECT COUNT(DISTINCT(left(CONVERT(char(8),vend_dt,112),6))) FROM VENDAS b where b.vend_clie_id = a.clie_id and b.vend_dt between DATEADD(YEAR,-2,@max_vend_dt)+1 and  DATEADD(YEAR,-1,@max_vend_dt)),0)	as 'qtd_meses_2ano',
			ISNULL((SELECT COUNT(DISTINCT(left(CONVERT(char(8),vend_dt,112),6))) FROM VENDAS b where b.vend_clie_id = a.clie_id and b.vend_dt between DATEADD(YEAR,-3,@max_vend_dt)+1 and  DATEADD(YEAR,-2,@max_vend_dt)),0)	as 'qtd_meses_3ano',

			null	as 'qtd_meses_4ano',
			null	as 'qtd_meses_5ano',
			null	as 'qtd_meses_6ano'
																																													   
	from	clientes a join temp_diag_fase1_perf_clie c on a.clie_cpf = c.cliente_cpf
	where	isnull(a.clie_id, '') <> ''

	-- Atualizar a fato de clientes
	update	temp_diag_fase1_perf_clie
			-- Primeira e última data de venda
	set		dt_venda_menor = b.dt_venda_menor,
			dt_venda_maior = b.dt_venda_maior,
			-- Indica se o cliente comprou, ou não, nos últimos 3 anos
			comprou1ano  = b.comprou1ano,
			comprou2anos = b.comprou2anos,
			comprou3anos = b.comprou3anos,
			comprou4anos = b.comprou4anos,
			comprou5anos = b.comprou5anos,
			comprou6anos = b.comprou6anos,

			-- Faturamento mensal no ano corrente
			Faturamento01 = b.Faturamento01,
			Faturamento02 = b.Faturamento02,
			Faturamento03 = b.Faturamento03,
			Faturamento04 = b.Faturamento04,
			Faturamento05 = b.Faturamento05,
			Faturamento06 = b.Faturamento06,
			faturamento07 = b.Faturamento07,
			Faturamento08 = b.Faturamento08,
			Faturamento09 = b.Faturamento09,
			Faturamento10 = b.Faturamento10,
			Faturamento11 = b.Faturamento11,
			Faturamento12 = b.Faturamento12,
			FaturamentoTotal = b.FaturamentoTotal,
			Faturamento1ano = b.Faturamento1ano,
			Faturamento2ano = b.Faturamento2ano,
			Faturamento3ano = b.Faturamento3ano,
			Faturamento4ano = b.Faturamento4ano,
			Faturamento5ano = b.Faturamento5ano,
			Faturamento6ano = b.Faturamento6ano,
			Faturamento1Ano_b2c = b.Faturamento1Ano_b2c,

			-- Quantidade de atendimentos (frequencia) por mês no ano corrente
			Atendimentos01		= case b.Atendimentos01		when 0 then null else b.atendimentos01		end,
			Atendimentos02		= case b.Atendimentos02		when 0 then null else b.atendimentos02		end,
			Atendimentos03		= case b.Atendimentos03		when 0 then null else b.atendimentos03		end,
			Atendimentos04		= case b.Atendimentos04		when 0 then null else b.atendimentos04		end,
			Atendimentos05		= case b.Atendimentos05		when 0 then null else b.atendimentos05		end,
			Atendimentos06		= case b.Atendimentos06		when 0 then null else b.atendimentos06		end,
			Atendimentos07		= case b.Atendimentos07		when 0 then null else b.atendimentos07		end,
			Atendimentos08		= case b.Atendimentos08		when 0 then null else b.atendimentos08		end,
			Atendimentos09		= case b.Atendimentos09		when 0 then null else b.atendimentos09		end,
			Atendimentos10		= case b.Atendimentos10		when 0 then null else b.atendimentos10		end,
			Atendimentos11		= case b.Atendimentos11		when 0 then null else b.atendimentos11		end,
			Atendimentos12		= case b.Atendimentos12		when 0 then null else b.atendimentos12		end,
			AtendimentosTotal	= case b.AtendimentosTotal	when 0 then null else b.atendimentostotal	end,
			Atendimentos1ano	= case b.Atendimentos1ano	when 0 then null else b.atendimentos1ano	end,
			Atendimentos2ano	= case b.Atendimentos2ano	when 0 then null else b.atendimentos2ano	end,
			Atendimentos3ano	= case b.Atendimentos3ano	when 0 then null else b.atendimentos3ano	end,
			Atendimentos4ano	= case b.Atendimentos4ano	when 0 then null else b.atendimentos4ano	end,
			Atendimentos5ano	= case b.Atendimentos5ano	when 0 then null else b.atendimentos5ano	end,
			Atendimentos6ano	= case b.Atendimentos6ano	when 0 then null else b.atendimentos6ano	end,
			Atendimentos1ano_b2c = case b.Atendimentos1ano_b2c	when 0 then null else b.Atendimentos1ano_b2c	end,
			-- Quantidade de meses em que o cliente comprou
			qtd_meses_1ano = b.qtd_meses_1ano,
			qtd_meses_2ano = b.qtd_meses_2ano,
			qtd_meses_3ano = b.qtd_meses_3ano,
			qtd_meses_4ano = b.qtd_meses_4ano,
			qtd_meses_5ano = b.qtd_meses_5ano,
			qtd_meses_6ano = b.qtd_meses_6ano

	from	temp_diag_fase1_perf_clie a join ##TEMP5 b on a.cliente_id COLLATE DATABASE_DEFAULT = b.cliente_id COLLATE DATABASE_DEFAULT

	-- Determinar a segmentação (ativos, inativos, nunca ativos, etc.)
	---------------------------------------------------------------------
	---------------------------------------------------------------------
	-- no cliente Monte Carlo o ano usado para segmentação é de 24 meses
	---------------------------------------------------------------------
	---------------------------------------------------------------------
	if object_id('tempdb..##temp4','u') is not null
		drop table ##temp4

	create table ##temp4 (
		seg_cliente_id	varchar(100),
		dt_venda_maior	datetime,
		segmento		varchar(100)
	)

	update	##temp4
	set		segmento = null
	
	insert	into ##temp4
	select	a.cliente_id, a.dt_venda_maior, null
	from	##temp5 as a
	where	isnull(a.regra_ouro, '') = ''

	update	##temp4
	set		segmento = 'Nunca Ativo'
	where	ISNULL(dt_venda_maior, '') = ''

	update	##temp4
	set		segmento = 'Ativo'
	where	dt_venda_maior > dateadd(month, -12, @max_vend_dt) and dt_venda_maior <= @max_vend_dt
	
	update	##temp4
	set		segmento = 'Inativo'
	where	dt_venda_maior > dateadd(month, -24, @max_vend_dt) and dt_venda_maior <= dateadd(month, -12, @max_vend_dt) 
	
	update	##temp4
	set		segmento = 'Perdido'
	where	dt_venda_maior <= dateadd(month, -24, @max_vend_dt) 
						
	update	temp_diag_fase1_perf_clie 
	set		segmento = tb2.segmento 
	from	temp_diag_fase1_perf_clie	as tb1 
			inner join ##temp4			as tb2 
			on tb1.cliente_id COLLATE DATABASE_DEFAULT = tb2.seg_cliente_id COLLATE DATABASE_DEFAULT

	where	tb1.cpf_curinga = 'N' and tb1.cpf_dup = 'N' and tb1.cpf_valido = 'S'

	

	-- Calcular o produto que cada cliente mais comprou
	create table ##temp6 (
				clie_id		varchar(250),
				linha		varchar(250),
				prod_nome	varchar(250),
				qtd			int,
				valor		money)

 	insert into ##temp6 (clie_id, linha, prod_nome, qtd, valor)
 	select	v.vend_clie_id		clie_id, 
 			p.prod_linha		linha,
			p.prod_nome			prod_nome,
 			count(*)			qtd, 
 			sum(i.iven_valor)	valor
 
 	from	itens_vendidos i 
			
			inner join vendas v 
			on v.vend_id = i.iven_vend_id
 			
			inner join produtos p 
			on p.prod_id = i.iven_prod_id

 	where	v.vend_clie_id is not null
 			and p.prod_linha is not null

 	group	by v.vend_clie_id, p.prod_linha, p.prod_nome
 
 

	-- Identificar grupos indeterminados
	create table ##temp7 (
	clie_id varchar(250),
	maximo int)

	insert	into ##temp7
	select	clie_id, max(qtd)
	from	##temp6
	group	by clie_id
	having	max(qtd) > 1

	-- Excluir da tabela ##temp6 os registros com qtd abaixo do máximo
	delete	##temp6
	from	##temp6 t1 inner join ##temp7 t2 on t1.clie_id = t2.clie_id
	where	t1.qtd < t2.maximo

	truncate table ##temp7

	-- Identificar quem tem repetição de maximos
	insert	into ##temp7 (clie_id, maximo)
	select	clie_id, qtd
	from	##temp6
	group	by clie_id, qtd
	having	count(*) > 1

	-- Setar os registros INVALIDOS
	update	t1
	set		linha = 'INVALIDO'
	from	##temp6 t1 inner join ##temp7 t2 on t1.clie_id = t2.clie_id

	-- Excluir os registros INVALIDOS
	delete	
	from	##temp6
	where	linha = 'INVALIDO'

	-- Atualizar a fato de clientes
	update	t1
	set		t1.produto_linha = t2.linha,
			t1.produto_nome  = t2.prod_nome

	from	temp_diag_fase1_perf_clie t1 
	
	inner join ##temp6 t2 
	on t1.cliente_id COLLATE DATABASE_DEFAULT = t2.clie_id COLLATE DATABASE_DEFAULT 


	update	temp_diag_fase1_perf_clie 
	set		produto_linha = ''
	where	produto_linha is null


	-- Determinar a faixa de produto
	create	table ##temp8 (
	clie_id varchar(250),
	valor money)

	insert	into ##temp8 (clie_id, valor)
	select	t1.cliente_id, max(iven_valor)
	from	temp_diag_fase1_perf_clie t1 inner join vendas v on t1.cliente_id = v.vend_clie_id
			inner join itens_vendidos i on i.iven_vend_id = v.vend_id
--	where	--i.iven_operacao = 'S'
	group	by t1.cliente_id


	update	t1
	set		produto_faixa = 
			case	when t2.valor <= 250						then 'Menor ou igual    a R$   250,00'
					when t2.valor  > 250  and t2.valor <=	350	then 'Entre R$   250,01 e R$   350,00'
					when t2.valor  > 350  and t2.valor <=	500	then 'Entre R$   350,01 e R$   500,00'
					when t2.valor  > 500 and t2.valor <=	650	then 'Entre R$   500,01 e R$   650,00'
					when t2.valor  > 650 and t2.valor <=   1000	then 'Entre R$   650,01 e R$ 1.000,00'
					when t2.valor  > 1000						then 'Maior R$ 1.000,00              '
					else 'Não disponível' end
	from	temp_diag_fase1_perf_clie t1 inner join ##temp8 t2 on t1.cliente_id COLLATE DATABASE_DEFAULT = t2.clie_id COLLATE DATABASE_DEFAULT 

	update	temp_diag_fase1_perf_clie 
	set		produto_faixa = 'Não disponível'
	where	produto_faixa is null

	-- Ajustar a coluna cluster_programa
	update	temp_diag_fase1_perf_clie 
	set		cluster_programa = ''
	where	cluster_programa is null

	-- Limpar a coluna segmento
	update	temp_diag_fase1_perf_clie 
	set		segmento = ''
	where	segmento is null

	drop table ##temp6
	drop table ##temp7
	drop table ##temp8


----------------------------------------------------------------------
	-- Calcular o valor acumulado por cliente, produto e data
----------------------------------------------------------------------
	if object_id('tempdb..##temp_produto_mais_comprado_1compra','u') is not null
		drop table ##temp_produto_mais_comprado_1compra

	create	table ##temp_produto_mais_comprado_1compra (
		cliente_id		varchar(100),
		prod_id			varchar(250),
--		iven_qtd		int,
		vlr_acumulado	money )

	insert	into ##temp_produto_mais_comprado_1compra (cliente_id, prod_id, vlr_acumulado)

	select	t.cliente_id, prod_id, sum(vlr_acumulado) 
	from	##temp_acum_produto_detalhe t

	inner join temp_diag_fase1_perf_clie c
	on		venda_data = c.dt_venda_menor
			and
			t.cliente_id COLLATE DATABASE_DEFAULT = c.cliente_id COLLATE DATABASE_DEFAULT

	group	by t.cliente_id, prod_id
	having	max(iven_qtd) = max(iven_qtd)


	update	temp_diag_fase1_perf_clie 
	set		produto_mais_comprado_compra1	= prod_nome
	from	temp_diag_fase1_perf_clie as t 
	
	inner join ( 
			select cliente_id, prod_id
			from ##temp_produto_mais_comprado_1compra 
			group by cliente_id, prod_id
			having	max(vlr_acumulado) = max(vlr_acumulado) ) as t2 

	on	t.cliente_id COLLATE DATABASE_DEFAULT = t2.cliente_id COLLATE DATABASE_DEFAULT

	inner join produtos p
	on	p.prod_id COLLATE DATABASE_DEFAULT = t2.prod_id COLLATE DATABASE_DEFAULT

--- Desempenho 
	UPDATE A
	SET desempenho = CASE WHEN Comprou1ano = 'S' AND Comprou2anos = 'S' THEN 'Retido' 
						  WHEN Comprou1ano = 'S' AND Comprou2anos = 'N' and Comprou3anos = 'N' AND Comprou4anos = 'N' THEN 'Novo' 
						  WHEN Comprou1ano = 'S' AND Comprou2anos = 'N' AND Comprou3anos = 'S' OR Comprou4anos = 'S'THEN 'Resgatado'
						  END
	FROM temp_diag_fase1_perf_clie a
	WHERE segmento_base = 'ativos'
	

--- Loja de Primeira Compra

update b
	SET LOJA_PRI_COMPRA = a.vend_loja_id
	FROM temp_diag_fase1_perf_clie b 
			join (select DISTINCT A.vend_clie_id,A.vend_loja_id 
									from vendas a 
										join (SELECT VEND_CLIE_ID as VEND_CLIE_ID
													,MIN(VEND_DT) as min_vend_dt 
									FROM VENDAS GROUP BY VEND_CLIE_ID) b
			on a.vend_clie_id = b.vend_clie_id 
				and vend_dt = min_vend_dt) a 
	on b.cliente_id = a.vend_clie_id 


--	DECLARE @temp varchar(100)
--
--	DECLARE C01 CURSOR FOR
--	SELECT DISTINCT cliente_id
--	FROM temp_diag_fase1_perf_clie JOIN VENDAS ON VEND_CLIE_ID = CLIENTE_ID
--	OPEN C01
--	FETCH NEXT FROM C01 into @temp
--	WHILE @@FETCH_STATUS = 0
--	
--	BEGIN
--	
--	UPDATE temp_diag_fase1_perf_clie
--		SET LOJA_PRI_COMPRA = b.vend_loja_id
--	FROM temp_diag_fase1_perf_clie A JOIN 
--		(SELECT TOP (1) ISNULL(VEND_CLIE_ID,NULL) as vend_clie_id, ISNULL(VEND_LOJA_ID,NULL) as vend_loja_id 
--			FROM VENDAS 
--		WHERE VEND_CLIE_ID = @TEMP 
--		ORDER BY VEND_DT ASC,VEND_CLIE_ID) b
--	on a.cliente_id = b.vend_Clie_id
--
--	FETCH NEXT FROM C01 into @temp
--
--	END
--
--	CLOSE C01
--	DEALLOCATE C01


--- Peças B2c

	UPDATE A
	SET Qtd_pecas_b2c = (SELECT  SUM(IVEN_QTD) 
									FROM ITENS_VENDIDOS 
										JOIN VENDAS 
											ON VEND_ID = IVEN_VEND_ID 
										JOIN CLIENTES b
											ON VEND_CLIE_ID = CLIE_ID
									WHERE VEND_LOJA_ID = '000042' AND a.cliente_id = b.clie_id and vend_dt > dateadd(month, -12, @max_vend_dt) and vend_dt <= @max_vend_dt)
		 		


	FROM temp_diag_fase1_perf_clie a


--- Poder de Compra B2c

	-- Determinar a faixa de produto
	create	table ##tempb2c8 (
	clie_id varchar(250),
	valor money)

	insert	into ##tempb2c8 (clie_id, valor)
	select	t1.cliente_id, max(iven_valor)
	from	temp_diag_fase1_perf_clie t1 inner join vendas v on t1.cliente_id = v.vend_clie_id
			inner join itens_vendidos i on i.iven_vend_id = v.vend_id
	where v.VEND_LOJA_ID = '000042'
	group	by t1.cliente_id


	update	t1
	set		produto_faixa_b2c = 
			case	when t2.valor <= 150						then 'Menor ou igual    a R$   150,00'
					when t2.valor  > 150  and t2.valor <=	300	then 'Entre R$   150,01 e R$   300,00'
					when t2.valor  > 300  and t2.valor <=	500	then 'Entre R$   300,01 e R$   500,00'
					when t2.valor  > 500 and t2.valor <=	800	then 'Entre R$   500,01 e R$   650,00'
					when t2.valor  > 800 and t2.valor <=   1000	then 'Entre R$   800,01 e R$ 1.000,00'
					when t2.valor  > 1000 and t2.valor <=  1500 then 'Entre R$   1000,01 e R$ 1.500,00'
					when t2.valor > 1500 then 'Maior R$ 1.500,00'
					else 'Não disponível' end
	from	temp_diag_fase1_perf_clie t1 inner join ##tempb2c8 t2 on t1.cliente_id COLLATE DATABASE_DEFAULT = t2.clie_id COLLATE DATABASE_DEFAULT 
			
END


--- Produto mais comprado no b2c

	-- Calcular o valor acumulado por cliente, produto e data
	if object_id('tempdb..##temp_acum_produto_detalhe_b2c','u') is not null
		drop table ##temp_acum_produto_detalhe_b2c

	create	table ##temp_acum_produto_detalhe_b2c (
		cliente_id		varchar(100),
		prod_id			varchar(250),
		venda_data		datetime,
		iven_qtd		int,
		vlr_acumulado	money )

	insert	into ##temp_acum_produto_detalhe_b2c (cliente_id, prod_id, venda_data, iven_qtd, vlr_acumulado)
	select	vend_clie_id, iven_prod_id, vend_dt, 
			sum(iven_qtd)		iven_qtd,
			sum(vend_vlr_final) vlr_acumulado
	from	vendas v

	inner	join ITENS_VENDIDOS i
	on		v.vend_id COLLATE DATABASE_DEFAULT = i.iven_vend_id COLLATE DATABASE_DEFAULT

	where	isnull(vend_clie_id, '') <> '' and vend_loja_id = '000042'
	group	by vend_clie_id, iven_prod_id, vend_dt


	-- Calcular o valor acumulado por cliente, produto e data
	if object_id('tempdb..##temp_acum_produto_b2c','u') is not null
		drop table ##temp_acum_produto_b2c

	create	table ##temp_acum_produto_b2c (
		cliente_id		varchar(100),
		prod_id			varchar(250),
		vlr_acumulado	money )

	insert	into ##temp_acum_produto_b2c (cliente_id, prod_id, vlr_acumulado)

	select	cliente_id, prod_id, max(vlr_acumulado)
	from	##temp_acum_produto_detalhe_b2c
	where	venda_data between dateadd(month, -12, @max_vend_dt) and @max_vend_dt
	group	by cliente_id, prod_id
	having	max(vlr_acumulado) = max(vlr_acumulado)


	update	temp_diag_fase1_perf_clie 
	set		produto_mais_comprado_12meses_b2c	= prod_nome
	from	temp_diag_fase1_perf_clie as t 
	
	inner join ##temp_acum_produto_b2c as t2 
	on	t.cliente_id COLLATE DATABASE_DEFAULT = t2.cliente_id COLLATE DATABASE_DEFAULT

	inner join produtos p
	on	p.prod_id COLLATE DATABASE_DEFAULT = t2.prod_id COLLATE DATABASE_DEFAULT

-- Antharys Vinicius: Inclusão da primeira venda, segunda venda, recência e frequencia após a primeira venda. 

-- primeira venda de todos os clientes
update temp_diag_fase1_perf_clie
set dt_primeira_compra = primeira_compra , 
	val_primeira_compra = valor_primeira_compra 
	from (
select v.vend_clie_id,vend_dt,primeira_compra,sum(vend_vlr_final) valor_primeira_compra from vendas v ,
(select vend_clie_id , min(vend_dt) primeira_compra from vendas group by vend_clie_id ) v_pri_compra
where v.vend_clie_id=v_pri_compra.vend_clie_id and v.vend_dt=v_pri_compra.primeira_compra
group by v.vend_clie_id,vend_dt,primeira_compra ) result
where cliente_id=vend_clie_id	

-- Segunda venda todos os clientes 


update temp_diag_fase1_perf_clie 
set dt_segunda_compra = dt_seg , 
	val_segunda_compra = valor_seg 
from ( 
		select v.vend_clie_id,v.vend_dt,v.vend_dt dt_seg,sum(v.vend_vlr_final) valor_seg
		from vendas v ,
					(
		select vend_clie_id,min(vend_dt) vend_dt
		from vendas v			
		where not  exists ( select 1 from 
							 (select vend_clie_id , min(vend_dt) primeira_compra from vendas group by vend_clie_id ) vpri
							 where v.vend_clie_id=vpri.vend_clie_id 
							 and   v.vend_dt    = vpri.primeira_compra )
		--and v.vend_clie_id=768
		group by vend_clie_id
		) v_seg_compra
					where v.vend_clie_id=v_seg_compra.vend_clie_id and 
						  v.vend_dt=v_seg_compra.vend_dt --and 
						  --v.vend_vlr_final > 0
		--and v.vend_clie_id=768
		group by v.vend_clie_id,v.vend_dt,v.vend_dt
	) result
where cliente_id=vend_clie_id	

-- Recência após primeira compra 

update temp_diag_fase1_perf_clie
set		qtd_dias_pos_primeira_compra	= (select datediff(day, dt_primeira_compra, dt_segunda_compra) )

-- Recência em Meses

update temp_diag_fase1_perf_clie
set qtd_mes_pos_primeira_compra = 
	   case  
	   when qtd_dias_pos_primeira_compra < 30 then 'Mesmo Mes' 
	   when  qtd_dias_pos_primeira_compra < 60 then '1 Mes' 
	   when  qtd_dias_pos_primeira_compra < 90 then '2 Mes' 
	   when qtd_dias_pos_primeira_compra < 120 then '3 Mes' 
	   when qtd_dias_pos_primeira_compra < 150 then '4 Mes' 
	   when  qtd_dias_pos_primeira_compra < 180 then '5 Mes' 
	   when  qtd_dias_pos_primeira_compra < 210 then '6 Mes' 
	   when qtd_dias_pos_primeira_compra > 210 then '7 ou mais'
	   end  




-- Frequencia após primeira compra 

update temp_diag_fase1_perf_clie
set		qtd_atend_pos_primeira_compra	
		= (select count(*) 
		from (select distinct vend_clie_id,vend_dt from vendas  ) v 
			where	v.vend_clie_id  = cliente_id  and 
					vend_dt between (dt_primeira_compra+1) and getdate())


GO

