USE [animale]
GO
/****** Object:  StoredProcedure [dbo].[spCalculateRegraOuro]    Script Date: 21/07/2014 14:42:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spCalculateRegraOuro]
AS
	DECLARE
	@mVHigh				money,
	@dtRef				datetime,
	@iInterval			int,
	@iIntervalPotential int,
    @V_DT_INICIO		DATETIME,
	@V_DT_FIM			DATETIME

BEGIN

	select 
		@mVHigh = PARA_V_HIGH,
		@dtRef = PARA_DT,
		@iInterval = PARA_INTERVAL,
		@iIntervalPotential = PARA_INTERVAL_POTENTIAL
	from PARAMETROS

	update CLIENTES 
	set CLIE_STATUS='S'

		update CLIENTES set CLIE_STATUS='S', CLIE_ATIVO = 'N', CLIE_REGRA_OURO = ''

	/* Participantes do Programa */

	UPDATE	A
	SET		A.CLIE_STATUS = 'N',
			A.CLIE_REGRA_OURO = A.CLIE_REGRA_OURO + 'NOME-'
	FROM	CLIENTES AS A
	WHERE	ISNULL(A.CLIE_NOME,'') = ''

	UPDATE	A
	SET		A.CLIE_STATUS = 'N',
			A.CLIE_REGRA_OURO = A.CLIE_REGRA_OURO + 'FUNC-'
	FROM	CLIENTES AS A
	WHERE	EXISTS	(	SELECT	1
						FROM	FUNCIONARIOS AS B
						WHERE	B.FUNC_CPF = A.CLIE_CPF)

	UPDATE	A
	SET		A.CLIE_STATUS = 'N',
			A.CLIE_REGRA_OURO = A.CLIE_REGRA_OURO + 'CPF-'
	FROM	CLIENTES AS A
	WHERE	A.CLIE_STATUS_CPF = 'N'

	UPDATE	A
	SET		A.CLIE_STATUS = 'N',
			A.CLIE_REGRA_OURO = A.CLIE_REGRA_OURO + 'LOJA-'
	FROM	CLIENTES AS A
	WHERE	dbo.fncValidateLoja(ISNULL(A.CLIE_LOJA_ID,'')) = 'N'

	UPDATE	A
	SET		A.CLIE_STATUS = 'N',
			A.CLIE_REGRA_OURO = A.CLIE_REGRA_OURO + 'SEXO-'
	FROM	CLIENTES AS A
	WHERE	A.CLIE_SEXO = 'M'

	UPDATE	A
	SET		A.CLIE_STATUS = 'N',
			A.CLIE_REGRA_OURO = A.CLIE_REGRA_OURO + 'CONTATO-'
	FROM	CLIENTES AS A
	WHERE	[dbo].fncValidateCel(CLIE_CEL) = 'N' AND 
			[dbo].fncValidateTel(CLIE_TEL) = 'N' AND
			CLIE_STATUS_ENDERECO = 'N' AND
			CLIE_STATUS_EMAIL = 'N'





	/* Participantes do Programa */
/*	update CLIENTES 
	set CLIE_STATUS='N'
	from CLIENTES left join LOJAS
	     on CLIE_LOJA_ID=LOJA_ID
		 left join FUNCIONARIOS
		 on CLIE_CPF = FUNC_CPF
	where 
	   isnull(CLIE_SEXO, '') = 'M'
	   or CLIE_STATUS_CPF='N'
	   or isnull(CLIE_NOME, '')=''	
	   or isnull(LOJA_STATUS,'N')='N'
	   or isnull(FUNC_CPF, '') <> ''

	update CLIENTES 
	set CLIE_STATUS='N'
	where CLIE_CPF IN ('31610919734',
                       '37221000700',
                       '81297742753',
                       '05680791757',
                       '00062258885',
                       '30615913890',
                       '22048367291')

*/

		UPDATE A 
		SET    CLIE_STATUS_EMAIL = 'N' 
		FROM   animale.dbo.clientes a 
			   JOIN i9.dbo._tmp_email_erro_permanente b 
				 ON a.clie_email = b.email 
					AND b.nome_banco = 'animale' 
		WHERE  clie_email IS NOT NULL 

		UPDATE A 
		SET    CLIE_STATUS_ERRO_EMAIL = 'S' 
		FROM   animale.dbo.clientes a 
			   JOIN i9.dbo._tmp_email_erro_permanente b 
				 ON a.clie_email = b.email 
					AND b.nome_banco = 'animale' 
		WHERE  clie_email IS NOT NULL 



	/* Loja de preferencia */

-- NOVA ROTINA DE LOJA PREFERENCIAL DO BOB

    SELECT @V_DT_FIM    = MAX(VEND_DT),
           @V_DT_INICIO = DATEADD(YEAR,-1,MAX(VEND_DT))+1
    FROM VENDAS

	update A 
	set    A.CLIE_LOJA_ID_PREF = isnull(DBO.FN_PRINCIPAL_LOJA(A.CLIE_ID,@V_DT_INICIO,@V_DT_FIM),clie_loja_id)
    from   clientes as a
--    where  A.CLIE_STATUS = 'S' AND
--           exists (select 1
--                   from   vendas as b,
--                          lojas as c
--                   where  b.vend_clie_id = a.clie_id and
--                          b.vend_loja_id = c.loja_id and
--                          c.loja_status = 'S' and
--                          b.vend_vlr_final > 0 and
--                          b.vend_dt between @v_dt_inicio and @v_dt_fim)
                  
-- VALOR ACUMULADO 06 MESES

	UPDATE CLIENTES
	SET    CLIE_VALOR_ACUMULADO_06 = ISNULL((SELECT SUM(VEND_VLR_FINAL) 
                                             FROM   VENDAS 
                                             WHERE  VENDAS.VEND_CLIE_ID = CLIENTES.CLIE_ID AND
                                                    VENDAS.VEND_DT BETWEEN DATEADD(MONTH,-6,@V_DT_FIM)+1 AND @V_DT_FIM),0)
    WHERE  CLIE_STATUS = 'S'

-- FREQ ACUMULADA 12 MESES

	UPDATE CLIENTES
	SET    CLIE_FREQ_ACUM_12 = ISNULL((SELECT COUNT(DISTINCT(VEND_DT))
                                       FROM   VENDAS 
                                       WHERE  VENDAS.VEND_CLIE_ID = CLIENTES.CLIE_ID AND
                                              VENDAS.VEND_DT BETWEEN DATEADD(MONTH,-12,@V_DT_FIM)+1 AND @V_DT_FIM),0)
    WHERE  CLIE_STATUS = 'S'

-- DATA ULTIMA COMPRA

	UPDATE CLIENTES
	SET    CLIE_DT_ULT_COMPRA   = (SELECT MAX(VEND_DT) FROM VENDAS WHERE VENDAS.VEND_CLIE_ID = CLIENTES.CLIE_ID),
	       CLIE_DT_PRI_COMPRA   = (SELECT MIN(VEND_DT) FROM VENDAS WHERE VENDAS.VEND_CLIE_ID = CLIENTES.CLIE_ID),
	       CLIE_FREQ_TOTAL      = (SELECT COUNT(*) FROM VENDAS WHERE VENDAS.VEND_CLIE_ID = CLIENTES.CLIE_ID),
	       CLIE_MAIOR_INTERVALO = DBO.FN_CALCULA_MAIOR_INTERVALO(CLIE_ID,'2000/01/01',GETDATE())
	WHERE  CLIE_STATUS = 'S'

-- ACUMULADO JOIAS

    update a
    set    a.CLIE_VALOR_ACUMULADO_12_JOIAS  =
           isnull((select sum(((c.iven_valor-c.iven_desconto)*c.iven_qtd))
                   from   vendas as b,
                          itens_vendidos as c,
                          produtos as d
                   where  b.vend_clie_id = a.clie_id and
                          b.vend_id = c.iven_vend_id and
                          c.iven_prod_id = d.prod_id and
                          b.vend_dt between DATEADD(MONTH,-12,@V_DT_FIM)+1 AND @V_DT_FIM and
                          d.prod_linha = 'JOIAS'),0)
    from   clientes as a                 
    where  a.clie_status = 'S'

    update a
    set    a.CLIE_VALOR_ACUMULADO_13_24_JOIAS  =
           isnull((select sum(((c.iven_valor-c.iven_desconto)*c.iven_qtd))
                   from   vendas as b,
                          itens_vendidos as c,
                          produtos as d
                   where  b.vend_clie_id = a.clie_id and
                          b.vend_id = c.iven_vend_id and
                          c.iven_prod_id = d.prod_id and
                          b.vend_dt between DATEADD(MONTH,-24,@V_DT_FIM)+1 AND DATEADD(MONTH,-12,@V_DT_FIM) and
                          d.prod_linha = 'JOIAS'),0)
    from   clientes as a                 
    where  a.clie_status = 'S'


-- ACERTOS CELULAR SP - 9 DIGITO

	update	clientes
	set		clie_cel = '9' + ltrim(rtrim(clie_cel))
	where	clie_status = 'S' and
			clie_cel_ddd = '11' and
			len(ltrim(rtrim(isnull(clie_cel,'')))) = 8 and
			dbo.fncValidateCel(clie_cel) = 'S' and
            substring(ltrim(rtrim(clie_cel)),1,2) not in ('70','77','78','79')

END




