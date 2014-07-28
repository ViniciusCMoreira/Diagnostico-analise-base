SET NOCOUNT ON



use animale

--
-- OBS As tabelas BK_ foram geradas a partir das tabelas TMP antes da execução da consistência
-- pois este processo limpa várias das inconsistências da base de dados.
--

Print '#   Quantidade de objetos carregados por tabela e IDs distintos'

Print '#  Clientes BK'
select count(*) Registros ,count(distinct(cliente_id)) Registros_dist from _tmp_clientes

Print '#  Clientes TMP'
select count(*),count(distinct(cliente_id)) from _tmp_clientes

Print '#   Clientes apos carga '
select count(*),count(distinct(clie_id)) from clientes

Print '#  ID Cliente não únicos e qtd - Entre aspas para identificar espaços em branco'
select '"'+cliente_id+'"',count(*)
from _tmp_clientes group by cliente_id 
having count(cliente_id) > 1

select count(cliente_id) 'id Cliente  nulos'
from _tmp_clientes where cliente_id is null 

Print '#  Ids Lojas que existem na tabela de cliente que não estão na tabela de lojas '

select distinct a.loja_id
from   _tmp_clientes as a
where  not exists (select 1
                   from   _tmp_lojas as b
                   where  b.loja_id = a.loja_id)
order by 1
Print '#  Ids Lojas que existem na tabela de cliente que não estão na tabela de lojas animale '

select distinct a.loja_id
from   _tmp_clientes as a
where  not exists (select 1
                   from   _tmp_lojas as b
                   where  b.loja_id = a.loja_id)
order by 1

--select a.cliente_id,a.cliente_cpf
--from   _tmp_clientes as a
--where  not exists (select 1
--                   from   _tmp_lojas as b
--                   where  b.loja_id = a.loja_id)

Print '#  Cliente_id não cadastrados um uma das lojas da lista'		

select count(*)
from   _tmp_clientes as a
where  not exists (select 1
                   from   _tmp_lojas as b
                   where  b.loja_id = a.loja_id)								   
				   
Print '#  QTD Cliente sem loja de cadastro'		

select count(*)
from   clientes as a
where  clie_loja_id is null							   
				   
		   				   
--select a.cliente_id,a.cliente_cpf,a.loja_id
--from   _tmp_clientes as a
--where  not exists (select 1
--                   from   _tmp_lojas as b
--                   where  b.loja_id = a.loja_id)								   
				   
-- DUVIDA na tmp não tem vendedor preferencial.
/*
select distinct a.vendor_id
from   _tmp_clientes as a
where  not exists (select 1
                   from   _tmp_vendedores as b
                   where  b.vendor_id = a.vendor_id)
*/

Print '#  Id loja na tabela de vendas que não existe na tabela de lojas '
select distinct a.loja_id
from   _tmp_vendas as a
where  not exists (select 1
                   from   _tmp_lojas as b
                   where  b.loja_id = a.loja_id)

                   
Print '#  id Vendedor na tabela de venda que não existem na tabela vendedor'
select distinct a.vendor_id
from   _tmp_vendas as a
where  not exists (select 1
                   from  _tmp_vendedores as b
                   where  b.vendor_id = a.vendor_id)

Print '#  ID Clientes na tabela de Vendas que não existem na tabela de clientes'                   
select distinct a.cliente_id
from   _tmp_vendas as a
where  not exists (select 1
                   from   _tmp_clientes as b
                   where  b.cliente_id = a.cliente_id)

select count( a.cliente_id ) as Qtd
from   _tmp_vendas as a
where  not exists (select 1
                   from   _tmp_clientes as b
                   where  b.cliente_id = a.cliente_id)

Print '#  Qtd de Vendas sem Itens '
select count(*)
from   _tmp_vendas as a
where  not exists (select 1
                   from   _tmp_itens_vendidos as b
                   where  b.venda_id = a.venda_id)
                   
Print '#  Id produtos na tabela de itens que não existem na tabela de produtos '

--select distinct a.prod_id
--from   _tmp_itens_vendidos as a
--where  not exists (select 1
--                   from   _tmp_produtos as b
--                   where  b.prod_id = a.prod_id)

select count(distinct a.prod_id) QTD_itens_fora_de_produtos
from   _tmp_itens_vendidos as a
where  not exists (select 1
                   from   _tmp_produtos as b
                   where  b.prod_id = a.prod_id)

Print '#  Itens na tabela de vendas que não aparecem na tabela de vendas '

select count(*)
from   _tmp_itens_vendidos as a
where  not exists (select 1
                   from   _tmp_vendas as b
                   where  b.venda_id = a.venda_id)

Print '#  Comparativo das quantidades com o processo completo de carga'

Print '#  Lojas'
select count(*),count(distinct(loja_id)) from _tmp_Lojas
Print '#  Lojas apos carga'
select count(*),count(distinct(loja_id)) from Lojas
Print '#  Vendedores'
select count(*),count(distinct(vendor_id)) from _tmp_Vendedores
Print '#  Vendedores apos carga'
select count(*),count(distinct(veno_id)) from Vendedores
Print '#  Produtos'
select count(*),count(distinct(prod_id)) from _tmp_Produtos
Print '#  Produtos apos carga'
select count(*),count(distinct(prod_id)) from  Produtos 
Print '#  Vendas'
select count(*),count(distinct(venda_id)) from bk_tmp_Vendas
Print '#  Vendas apos carga'
select count(*),count(distinct(vend_id)) from Vendas
Print '#  Itens por operacao'
select count(*) qtd,count(distinct(operacao)) operacao from _tmp_Itens_Vendidos 
Print '#  Itens e Venda+PROD+Operacao distintos'
select count(*),count(distinct((venda_id + '|' + prod_id + '|' + operacao)))  from _tmp_Itens_Vendidos
Print '#  Itens por operacao apos carga'
select count(*) qtd,count(distinct(iven_operacao)) operacao from Itens_Vendidos 
Print '#  Itens e Venda+PROD+Operacao distintos apos carga'
select count(*),cast(count(distinct((iven_vend_id  + '|' + iven_prod_id + '|' + cast(iven_operacao as varchar))))as varchar)  from Itens_Vendidos



/*-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
------------------------------------- CARGAS --------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

		CLIE_ID,
		CLIE_ESCI_ID,
		CLIE_BAIR_ID,
	    CLIE_CIDA_ID,
		CLIE_CPF,
		CLIE_CARTAO,
		CLIE_PROFISSAO,
		CLIE_LOJA_ID_PREF,
		CLIE_STATUS,
		CLIE_STATUS_CPF,
		CLIE_STATUS_CARTAO,
		CLIE_STATUS_ENDERECO,
		CLIE_STATUS_EMAIL,
		CLIE_LISTA,
		CLIE_FINALIDADE_ROUPA,
		CLIE_PERC_ANIMALE,
		CLIE_IDENTIFICA_MARCA,
		CLIE_FREQ_EMAILS,
		CLIE_APELIDO,
		CLIE_QTD_FILHOS,
		CLIE_IDADE_FILHO1,
		CLIE_IDADE_FILHO2,
		CLIE_IDADE_FILHO3,
		CLIE_OUTRA_LOJA1,
		CLIE_OUTRA_LOJA2,
		CLIE_OUTRA_LOJA3
		dbo.fncFormatAddress(cliente_tipo_log),
		dbo.fncFormatAddress(cliente_logradouro),
		dbo.fncFormatAddress(cliente_numero),
	--	dbo.fncFormatAddress(cliente_complemento),

-- delete from clientes
-- select count(*) from clientes


insert into clientes
(CLIE_ID, CLIE_CPF, CLIE_NOME, CLIE_SEXO, CLIE_DT_NASC, 
CLIE_UF, CLIE_CIDADE, CLIE_BAIRRO, 
-- --ENDERECO, 
 		CLIE_TIPO_LOG,		CLIE_LOGRADOURO,	CLIE_NUMERO ,
CLIE_COMPLEMENTO,
CLIE_CEP, 
CLIE_TEL_DDD, CLIE_TEL, CLIE_CEL_DDD, CLIE_CEL--, 
--CLIE_EMAIL, CLIE_LOJA_ID, 
----vendor_id, 
--CLIE_DT_CADASTRO, CLIE_DT_ALTERACAO
)
select 
LTRIM(RTRIM(UPPER(cliente_id))), LTRIM(RTRIM(UPPER(cliente_CPF))), LTRIM(RTRIM(UPPER(cliente_NOME))), LTRIM(RTRIM(UPPER(cliente_SEXO))), CONVERT(DATETIME,cliente_DT_NASC), 
LTRIM(RTRIM(UPPER(cliente_UF))), LTRIM(RTRIM(UPPER(cliente_CIDADE))), LTRIM(RTRIM(UPPER(cliente_BAIRRO))),
	 --  -- LTRIM(RTRIM(UPPER(ENDERECO))), 
LTRIM(RTRIM(UPPER(cliente_tipo_log))),		LTRIM(RTRIM(UPPER(cliente_logradouro))),		LTRIM(RTRIM(UPPER(cliente_numero))),
LTRIM(RTRIM(UPPER(cliente_COMPLEMENTO))), 
LTRIM(RTRIM(UPPER(replace(replace(cliente_cep,'-',''),'"','')))), 
LTRIM(RTRIM(UPPER(		(cliente_tel_ddd)))), LTRIM(RTRIM(UPPER(cliente_TEL))), LTRIM(RTRIM(UPPER(		(cliente_cel_ddd)))), LTRIM(RTRIM(UPPER(cliente_CEL)))--, 
  --     LTRIM(RTRIM(UPPER(cliente_EMAIL))), CONVERT(INT,loja_id), 
	 --  --LTRIM(RTRIM(UPPER(vendor_id))), 
	 --  CONVERT(DATETIME,cliente_DT_CADASTRO), CONVERT(DATETIME,cliente_DT_ALTERACAO)
from   _tmp_clientes
where
cliente_id <>  (' ')


insert into itens_vendidos
(venda_id, prod_id, OPERACAO, 
 QUANT, VLR_UNITARIO, VLR_DESCONTO, TOT_ITEM)
select LTRIM(RTRIM(UPPER(venda_id))), LTRIM(RTRIM(UPPER(prod_id))), LTRIM(RTRIM(UPPER(OPERACAO))), 
       CONVERT(INT,QUANT), CONVERT(DECIMAL(15,2),VLR_UNITARIO), CONVERT(DECIMAL(15,2),VLR_DESCONTO), CONVERT(DECIMAL(15,2),TOT_ITEM)
from   _tmp_itens_vendidos


UPDATE ITENS_VENDIDOS SET TOT_ITEM = TOT_ITEM * -1 WHERE OPERACAO = 'TROCA'
UPDATE ITENS_VENDIDOS SET QUANT    = QUANT    * -1 WHERE OPERACAO = 'TROCA'


INSERT INTO LOJAS
(loja_id, 
 NOME, UF, CIDADE, BAIRRO, CEP, 
 TOT_M2_LOJA, TOT_M2_VENDA)
SELECT CONVERT(INT,loja_id), 
       LTRIM(RTRIM(UPPER(NOME))), LTRIM(RTRIM(UPPER(UF))), LTRIM(RTRIM(UPPER(CIDADE))), LTRIM(RTRIM(UPPER(BAIRRO))), LTRIM(RTRIM(UPPER(CEP))), 
       CONVERT(DECIMAL(15,2),TOT_M2_LOJA), CONVERT(DECIMAL(15,2),TOT_M2_VENDA)
FROM   _TMP_LOJAS


INSERT INTO PRODUTOS
(prod_id, 
 NOME, 
 CATEGORIA, LINHA, COLECAO, 
 MATERIAL, GRUPO, ARTIGO, MODELO, 
 COR, TAMANHO)
SELECT LTRIM(RTRIM(UPPER(prod_id))), 
       LTRIM(RTRIM(UPPER(NOME))), 
       LTRIM(RTRIM(UPPER(CATEGORIA))), LTRIM(RTRIM(UPPER(LINHA))), LTRIM(RTRIM(UPPER(COLECAO))), 
       LTRIM(RTRIM(UPPER(MATERIAL))), LTRIM(RTRIM(UPPER(GRUPO))), LTRIM(RTRIM(UPPER(ARTIGO))), LTRIM(RTRIM(UPPER(MODELO))), 
       LTRIM(RTRIM(UPPER(COR))), LTRIM(RTRIM(UPPER(TAMANHO)))
FROM   _TMP_PRODUTOS


INSERT INTO VENDEDORES
(vendor_id, NOME)
SELECT LTRIM(RTRIM(UPPER(vendor_id))), LTRIM(RTRIM(UPPER(NOME)))
FROM   _TMP_VENDEDORES


INSERT INTO VENDAS
(venda_id, vendor_id, loja_id, cliente_id, 
 DT_VENDA, VLR_PAGO, QTDE, VLR_BRUTO, VLR_DESCONTO, 
 VLR_CARTAO_CRED, VLR_CARTAO_DEB, VLR_DINHEIRO, VLR_CHEQUES, 
 VLR_VALES, VLR_OUTROS, VLR_BONUS_EMITIDOS, VLR_BONUS_RESGATADOS)
SELECT  LTRIM(RTRIM(UPPER(venda_id))), LTRIM(RTRIM(UPPER(vendor_id))), CONVERT(INT,loja_id), LTRIM(RTRIM(UPPER(cliente_id))), 
        CONVERT(DATETIME,DT_VENDA), CONVERT(DECIMAL(15,2),VLR_PAGO), CONVERT(INT,QTDE), CONVERT(DECIMAL(15,2),VLR_BRUTO), CONVERT(DECIMAL(15,2),VLR_DESCONTO), 
        CONVERT(DECIMAL(15,2),VLR_CARTAO_CRED), CONVERT(DECIMAL(15,2),VLR_CARTAO_DEB), CONVERT(DECIMAL(15,2),VLR_DINHEIRO), CONVERT(DECIMAL(15,2),VLR_CHEQUES), 
        CONVERT(DECIMAL(15,2),VLR_VALES), CONVERT(DECIMAL(15,2),VLR_OUTROS), CONVERT(DECIMAL(15,2),VLR_BONUS_EMITIDOS), CONVERT(DECIMAL(15,2),VLR_BONUS_RESGATADOS)
FROM   _TMP_VENDAS


*/
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
------------------------------------- CLIENTES ------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------


Print ' 

##########  Análise de CLIENTES ########## 

'

--- Continuação após a rotina de carga padrão do Cliente Animale  
-- O processo de carga acima não é suportada pela modelagem atual das basses de dados.

Print '#  Avaliação do cliente após processo de carga/higienização'

Print '#   Total de clientes  '
select count(*) from clientes

Print '#   CPFs válidos  '
select i9.dbo.fncValidateCPF(clie_cpf),count(*) 
from   clientes
group  by i9.dbo.fncValidateCPF(clie_cpf)

--Print '#   CPFs válidos TMP '
--select i9.dbo.fncValidateCPF(cliente_cpf),count(*) 
--from   _tmp_clientes
--group  by i9.dbo.fncValidateCPF(cliente_cpf)

Print '#   CPFs distintos  '
SELECT COUNT(DISTINCT(clie_cpf))
FROM   CLIENTES
WHERE  i9.dbo.fncValidateCPF(clie_cpf) = 'S'

--Print '#   CPFs distintos TMP '
--SELECT COUNT(DISTINCT(cliente_cpf))
--FROM   _tmp_CLIENTES
--WHERE  i9.dbo.fncValidateCPF(cliente_cpf) = 'S'

Print '#  Clientes sem  nome '

select i9.dbo.fncValidateCPF(clie_cpf),count(*)
from   clientes
where  isnull(clie_nome,'') = ''
group  by i9.dbo.fncValidateCPF(clie_cpf)

--Print '#  Clientes sem  nome TMP '

--select i9.dbo.fncValidateCPF(cliente_cpf) Status_CPF ,count(*) QTD
--from   _tmp_CLIENTES
--where  isnull(cliente_nome,'') = ''
--group  by i9.dbo.fncValidateCPF(cliente_cpf)


Print '#  Distribuição clientes por sexo'

select i9.dbo.fncValidateCPF(clie_cpf),clie_sexo,count(*) 
from   clientes
group  by i9.dbo.fncValidateCPF(clie_cpf),clie_sexo
order  by i9.dbo.fncValidateCPF(clie_cpf),clie_sexo

select distinct clie_sexo from clientes

--Print '#  Distribuição clientes por sexo TMP'

--select i9.dbo.fncValidateCPF(cliente_cpf),cliente_sexo,count(*) 
--from   _tmp_CLIENTES
--group  by i9.dbo.fncValidateCPF(cliente_cpf),cliente_sexo
--order  by i9.dbo.fncValidateCPF(cliente_cpf),cliente_sexo


Print '#  Distribuição por mês de aniversario'

select i9.dbo.fncValidateCPF(clie_cpf),month(clie_dt_nasc),count(8)
from   clientes
group  by i9.dbo.fncValidateCPF(clie_cpf),month(clie_dt_nasc)
order  by i9.dbo.fncValidateCPF(clie_cpf),month(clie_dt_nasc)

--Print '#  Distribuição por mês de aniversario TMP'

--select i9.dbo.fncValidateCPF(cliente_cpf),month(cliente_dt_nasc),count(8)
--from   _tmp_clientes
--group  by i9.dbo.fncValidateCPF(cliente_cpf),month(cliente_dt_nasc)
--order  by i9.dbo.fncValidateCPF(cliente_cpf),month(cliente_dt_nasc)

Print '#  Distribuição por idade'

select i9.dbo.fncValidateCPF(clie_cpf) cpf_valido,i9.dbo.fncAge(clie_dt_nasc,getdate()) anos,count(8) qtd
from   clientes
group  by i9.dbo.fncValidateCPF(clie_cpf),i9.dbo.fncAge(clie_dt_nasc,getdate())
order  by i9.dbo.fncValidateCPF(clie_cpf),i9.dbo.fncAge(clie_dt_nasc,getdate())

print '# Análise de idade'
select i9.dbo.fncValidateCPF(clie_cpf) cpf_valido,clie_dt_nasc,i9.dbo.fncAge(clie_dt_nasc,getdate()) anos,count(8) qtd
from   clientes
group  by i9.dbo.fncValidateCPF(clie_cpf),clie_dt_nasc,i9.dbo.fncAge(clie_dt_nasc,getdate())
order  by clie_dt_nasc,i9.dbo.fncValidateCPF(clie_cpf)

--

select count(*) from clientes where clie_dt_nasc is  null ; -- 44.487
select count(*) from clientes where clie_dt_nasc is not null ; -- 388.242

Print '#  Clientes com endereços vazios/nulos'
/*
select i9.dbo.fncValidateCPF(clie_cpf) CPF_Valido,
       case when (
					  --isnull(i9.dbo.fncFormatAddress(endereco), '') = '' 
 	        	      isnull(i9.dbo.fncFormatAddress(clie_tipo_log), '') = '' 
				   or isnull(i9.dbo.fncFormatAddress(clie_logradouro), '') = '' 
				   or isnull(i9.dbo.fncFormatAddress(clie_numero), '') = '' 
				   or isnull(i9.dbo.fncFormatAddress(clie_cidade), '') = '' 
		           or isnull(i9.dbo.fncFormatAddress(clie_uf), '') = '' 
		           or isnull(i9.dbo.fncFormatAddress(clie_cep), '') = '') then 'N' else 'S' end Endereco_Preenchido,
       count(8) QTD
from   clientes
group  by  i9.dbo.fncValidateCPF(clie_cpf),
       case when (
					  --isnull(i9.dbo.fncFormatAddress(endereco), '') = '' 
 	        	      isnull(i9.dbo.fncFormatAddress(clie_tipo_log), '') = '' 
				   or isnull(i9.dbo.fncFormatAddress(clie_logradouro), '') = '' 
				   or isnull(i9.dbo.fncFormatAddress(clie_numero), '') = '' 
				   or isnull(i9.dbo.fncFormatAddress(clie_cidade), '') = '' 
		           or isnull(i9.dbo.fncFormatAddress(clie_uf), '') = '' 
		           or isnull(i9.dbo.fncFormatAddress(clie_cep), '') = '') then 'N' else 'S' end
order  by  i9.dbo.fncValidateCPF(clie_cpf),
       case when (
					  --isnull(i9.dbo.fncFormatAddress(endereco), '') = '' 
 	        	      isnull(i9.dbo.fncFormatAddress(clie_tipo_log), '') = '' 
				   or isnull(i9.dbo.fncFormatAddress(clie_logradouro), '') = '' 
				   or isnull(i9.dbo.fncFormatAddress(clie_numero), '') = '' 
				   or isnull(i9.dbo.fncFormatAddress(clie_cidade), '') = '' 
		           or isnull(i9.dbo.fncFormatAddress(clie_uf), '') = '' 
		           or isnull(i9.dbo.fncFormatAddress(clie_cep), '') = '') then 'N' else 'S' end
*/

select i9.dbo.fncValidateCPF(clie_cpf) CPF_Valido,
CASE WHEN	LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE((LTRIM(RTRIM(ISNULL(CLIE_TIPO_LOG,''))) + ' ' + LTRIM(RTRIM(ISNULL(CLIE_LOGRADOURO,''))) + ' ' + LTRIM(RTRIM(ISNULL(CLIE_NUMERO,''))) + ' ' + LTRIM(RTRIM(ISNULL(CLIE_COMPLEMENTO,'')))),'  ',' '),'  ',' '),'  ',' '),'  ',' '))) <> '' AND
												LTRIM(RTRIM(ISNULL(CLIE_CIDA_ID,''))) <> '' AND
												LTRIM(RTRIM(ISNULL(CLIE_UF,''))) <> '' AND
												LEN(LTRIM(RTRIM(ISNULL(CLIE_CEP,'')))) = 8 THEN 'S' ELSE 'N' END stat_end, 
	   count(*) 
from clientes 
		group by i9.dbo.fncValidateCPF(clie_cpf) ,
CASE WHEN	LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE((LTRIM(RTRIM(ISNULL(CLIE_TIPO_LOG,''))) + ' ' + LTRIM(RTRIM(ISNULL(CLIE_LOGRADOURO,''))) + ' ' + LTRIM(RTRIM(ISNULL(CLIE_NUMERO,''))) + ' ' + LTRIM(RTRIM(ISNULL(CLIE_COMPLEMENTO,'')))),'  ',' '),'  ',' '),'  ',' '),'  ',' '))) <> '' AND
												LTRIM(RTRIM(ISNULL(CLIE_CIDA_ID,''))) <> '' AND
												LTRIM(RTRIM(ISNULL(CLIE_UF,''))) <> '' AND
												LEN(LTRIM(RTRIM(ISNULL(CLIE_CEP,'')))) = 8 THEN 'S' ELSE 'N' END


Print '#   Clientes com numero de telefone válido'

select i9.dbo.fncValidateCPF(clie_cpf) CPF_Valido,
       CASE WHEN ISNUMERIC(ISNULL(clie_tel_ddd,'0')) = 0 THEN 'N' ELSE CASE WHEN CONVERT(int,ISNULL(clie_tel_ddd,'0')) BETWEEN 11 AND 99 THEN 'S' ELSE 'N' END END DDD_OK,
       i9.dbo.fncValidateTel(clie_tel) TEL_OK,
       count(8) Qtd
from   clientes
group  by i9.dbo.fncValidateCPF(clie_cpf),
          CASE WHEN ISNUMERIC(ISNULL(clie_tel_ddd,'0')) = 0 THEN 'N' ELSE CASE WHEN CONVERT(int,ISNULL(clie_tel_ddd,'0')) BETWEEN 11 AND 99 THEN 'S' ELSE 'N' END END,
          i9.dbo.fncValidateTel(clie_tel)
order  by i9.dbo.fncValidateCPF(clie_cpf),
          CASE WHEN ISNUMERIC(ISNULL(clie_tel_ddd,'0')) = 0 THEN 'N' ELSE CASE WHEN CONVERT(int,ISNULL(clie_tel_ddd,'0')) BETWEEN 11 AND 99 THEN 'S' ELSE 'N' END END,
          i9.dbo.fncValidateTel(clie_tel)

Print '#   Clientes com numero de celular válido
'

select i9.dbo.fncValidateCPF(clie_cpf) CPF_Valido,
       CASE WHEN ISNUMERIC(ISNULL(clie_cel_ddd,'0')) = 0 THEN 'N' ELSE CASE WHEN CONVERT(int,ISNULL(clie_cel_ddd,'0')) BETWEEN 11 AND 99 THEN 'S' ELSE 'N' END END DDD_Valido,
       i9.dbo.fncValidateCel(clie_cel) Celular_valido,
       count(8) Qtd
from   clientes
group  by i9.dbo.fncValidateCPF(clie_cpf),
          CASE WHEN ISNUMERIC(ISNULL(clie_cel_ddd,'0')) = 0 THEN 'N' ELSE CASE WHEN CONVERT(int,ISNULL(clie_cel_ddd,'0')) BETWEEN 11 AND 99 THEN 'S' ELSE 'N' END END,
          i9.dbo.fncValidateCel(clie_cel)
order  by i9.dbo.fncValidateCPF(clie_cpf),
          CASE WHEN ISNUMERIC(ISNULL(clie_cel_ddd,'0')) = 0 THEN 'N' ELSE CASE WHEN CONVERT(int,ISNULL(clie_cel_ddd,'0')) BETWEEN 11 AND 99 THEN 'S' ELSE 'N' END END,
          i9.dbo.fncValidateCel(clie_cel)

Print '#   Clientes com email válido
'
select i9.dbo.fncValidateCPF(clie_cpf) CPF_Valido,
       i9.dbo.fncValidateEmail('animale',clie_email) Email_Valido,
       count(8) Qtd
from   clientes
group  by i9.dbo.fncValidateCPF(clie_cpf),
          i9.dbo.fncValidateEmail('animale',clie_email)
order  by i9.dbo.fncValidateCPF(clie_cpf),
          i9.dbo.fncValidateEmail('animale',clie_email)


Print  'Distribuicao dt_cadastro'

select substring(convert(varchar,clie_dt_cadastro,111),1,7) DT_cadastro ,count(8) Qtd
from   clientes
group  by substring(convert(varchar,clie_dt_cadastro,111),1,7)
order  by substring(convert(varchar,clie_dt_cadastro,111),1,7)

Print  'Distribuicao dt_cadastro'
select substring(convert(varchar,clie_dt_alteracao,111),1,7) Dt_alteracao,count(8) Qtd
from   clientes
group  by substring(convert(varchar,clie_dt_alteracao,111),1,7)
order  by substring(convert(varchar,clie_dt_alteracao,111),1,7)

Print '#  Clientes sem lojas de cadastro'
select i9.dbo.fncValidateCPF(clie_cpf) CPF_Valido,count(*) Qtd
from   clientes as a
where  not exists (select 1
                   from   lojas as b
                   where  b.loja_id = a.clie_loja_id)
group  by i9.dbo.fncValidateCPF(clie_cpf)
order  by i9.dbo.fncValidateCPF(clie_cpf)

-- Vendedor não existe mais na tabela de clientes
--select i9.dbo.fncValidateCPF(clie_cpf),count(*)
--from   clientes as a
--where  not exists (select 1
--                   from   VENDEDORES as b
--                   where  b.vendor_id = a.vendor_id)
--group  by i9.dbo.fncValidateCPF(clie_cpf)
--order  by i9.dbo.fncValidateCPF(clie_cpf)

Print '#  Distribuição Clientes por Loja de Cadastro'

select b.loja_id LID,b.loja_nome LNOME,i9.dbo.fncValidateCPF(clie_cpf) cpf_valido,count(*) qtd
from   clientes as a,
       lojas as b
where  a.clie_loja_id = b.loja_id
group  by b.loja_id,b.loja_nome,i9.dbo.fncValidateCPF(clie_cpf)
order  by b.loja_id,b.loja_nome,i9.dbo.fncValidateCPF(clie_cpf)


--Print '#  Distribuicao vendedor '

--select b.vendor_id,b.clie_nome,i9.dbo.fncValidateCPF(clie_cpf),count(*)
--from   clientes as a,
--       vendedores as b
--where  a.vendor_id = b.vendor_id
--group  by b.vendor_id,b.clie_nome,i9.dbo.fncValidateCPF(clie_cpf)
--order  by b.vendor_id,b.clie_nome,i9.dbo.fncValidateCPF(clie_cpf)

Print '#  Distribuição clientes por uf/cidade/bairro'
SELECT clie_UF,clie_CIDADE,clie_BAIRRO,COUNT(8)
FROM   CLIENTES
GROUP  BY clie_UF,clie_CIDADE,clie_BAIRRO
ORDER  BY clie_UF,clie_CIDADE,clie_BAIRRO

Print '#  Distribuição clientes por uf/cidade/bairro - lookup'

SELECT X.UF,X.CIDADE,X.BAIRRO,COUNT(*)
FROM   (SELECT ISNULL((SELECT B.LKUF_TO FROM I9.dbo.LOOKUP_UFS AS B WHERE B.LKUF_FROM = LTRIM(RTRIM(UPPER(A.clie_UF)))),A.clie_UF) AS UF,
               ISNULL((SELECT B.LKCI_TO FROM I9.dbo.LOOKUP_CIDADES AS B WHERE B.LKCI_FROM = LTRIM(RTRIM(UPPER(A.clie_CIDADE)))),A.clie_CIDADE) AS CIDADE,
               ISNULL((SELECT B.LKBA_TO FROM I9.dbo.LOOKUP_BAIRROS AS B WHERE B.LKBA_FROM = LTRIM(RTRIM(UPPER(A.clie_BAIRRO)))),A.clie_BAIRRO) AS BAIRRO
        FROM   CLIENTES AS A) AS X
GROUP  BY X.UF,X.CIDADE,X.BAIRRO
ORDER  BY X.UF,X.CIDADE,X.BAIRRO
          
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
------------------------------------- LOJAS ---------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

Print ' 

##########  Análise de LOJAS ########## 

'
select count(*) from _tmp_lojas

Print '#  Lojas válidas'
SELECT COUNT(8) FROM LOJAS where loja_status = 'S'

Print '#  Lojas na carga'
SELECT COUNT(DISTINCT(loja_id)) FROM LOJAS

Print '#  Lojas sem nome'
SELECT COUNT(8) FROM LOJAS WHERE ISNULL(LTRIM(RTRIM(Loja_NOME)),'') = ''

Print '#  Lojas sem vendas '
SELECT  count(*) Qtd,loja_status  FROM LOJAS where loja_id not in (select vend_loja_id from vendas)
group by loja_status

print 'Detalhes de lojas '
select * from lojas 
--select * from _tmp_lojas
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
------------------------------------- VENDEDORES ----------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

Print ' 

##########  Análise de Vendedores ########## 

'


Print '#  Quantidade de Vendedores'

SELECT COUNT(8) FROM VENDEDORES

Print '#  Quantidade de Vendedores unicos'
SELECT COUNT(DISTINCT(veno_id)) FROM VENDEDORES

Print '#  Vendedores sem nome'
SELECT COUNT(8) FROM VENDEDORES WHERE ISNULL(LTRIM(RTRIM(veno_NOME)),'') = ''

       
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
------------------------------------- PRODUTOS ------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------


Print ' 

##########  Análise de Produtos ########## 

'


Print '#  Quantidade de produtos cadastrados'
SELECT COUNT(8) FROM PRODUTOS

Print '#  Quantidade de produtos unicos cadastrados'
SELECT COUNT(DISTINCT(prod_id)) FROM PRODUTOS

Print '#  Quantidade de produtos sem nome'
SELECT COUNT(8) FROM PRODUTOS WHERE ISNULL(LTRIM(RTRIM(prod_NOME)),'') = ''

Print '#  Quantidade de produtos por linha'
SELECT prod_LINHA,COUNT(8)
FROM   PRODUTOS
GROUP  BY prod_LINHA
ORDER  BY prod_LINHA

Print '#  Quantidade de produtos por coleção'
SELECT prod_COLECAO,COUNT(8)
FROM   PRODUTOS
GROUP  BY prod_COLECAO
ORDER  BY prod_COLECAO

Print '#  Quantidade de produtos por categoria'
SELECT prod_categoria,COUNT(8)
FROM   PRODUTOS
GROUP  BY prod_categoria
ORDER  BY prod_categoria

-- Não existe mais 
--Print '#  Quantidade de produtos por material'
--SELECT prod_MATERIAL,COUNT(8)
--FROM   PRODUTOS
--GROUP  BY prod_MATERIAL
--ORDER  BY prod_MATERIAL

-- Não existe a coluna grupo 
--SELECT prod_GRUPO,COUNT(8) select * from produtos
--FROM   PRODUTOS
--GROUP  BY prod_GRUPO
--ORDER  BY prod_GRUPO
-- Não existe a coluna artigo
--SELECT ARTIGO,COUNT(8)
--FROM   PRODUTOS
--GROUP  BY ARTIGO
--ORDER  BY ARTIGO

--SELECT MODELO,COUNT(8)
--FROM   PRODUTOS
--GROUP  BY MODELO
--ORDER  BY MODELO

--SELECT COR,COUNT(8)
--FROM   PRODUTOS
--GROUP  BY COR
--ORDER  BY COR

--SELECT TAMANHO,COUNT(8)
--FROM   PRODUTOS
--GROUP  BY TAMANHO
--ORDER  BY TAMANHO


Print '#  Quantidade de produtos por Marca'

SELECT prod_marca Marca,COUNT(8) qtd
FROM   PRODUTOS
GROUP  BY prod_marca
ORDER  BY prod_marca


-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
------------------------------------- VENDAS --------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------


Print ' 

##########  Análise de Vendas ########## 

'


Print '#  Qtd de vendas '
SELECT COUNT(*) FROM VENDAS

Print '#  Qtd de vendas distintas'
SELECT COUNT(DISTINCT(vend_id)) FROM VENDAS

Print '#  Qtd de vendas sem itens'
SELECT COUNT(8)
FROM   VENDAS AS A
WHERE  NOT EXISTS (SELECT 1
                   FROM   ITENS_VENDIDOS AS B
                   WHERE  B.iven_vend_id = A.vend_id)

Print '#  Qtd de vendas sem lojas'
SELECT COUNT(8)
FROM   VENDAS AS A
WHERE  NOT EXISTS (SELECT 1
                   FROM   LOJAS AS B
                   WHERE  B.loja_id = A.vend_loja_id)

Print '#  Qtd de vendas sem clientes'
SELECT (case when isnull(a.vend_clie_id,'')='' then 'N' else 'S' end) Cliente_preenchido,
       COUNT(8) Qtd
FROM   VENDAS AS A
group  by (case when isnull(a.vend_clie_id,'')='' then 'N' else 'S' end) 

Print '#  Qtd de vendas de clientes com CPF Valido'
SELECT (case when isnull(a.vend_clie_id,'')='' then 'N' else 'S' end) Cliente_preenchido ,
       i9.dbo.fncValidateCPF(B.clie_cpf) Status_CPF,       
       COUNT(8) QTD
FROM   VENDAS AS A LEFT OUTER JOIN CLIENTES AS B ON A.vend_clie_id = B.clie_id
group  by (case when isnull(a.vend_clie_id,'')='' then 'N' else 'S' end),
           i9.dbo.fncValidateCPF(B.clie_cpf)

Print '#  Qtd de vendas sem vendedores'
SELECT COUNT(8)
FROM   VENDAS AS A
WHERE  NOT EXISTS (SELECT 1
                   FROM   VENDEDORES AS B
                   WHERE  B.veno_id = A.vend_veno_id)

Print '#  Distribuição dos totais de vendas'
SELECT X.LOJA,
       X.ANOMES ano_mes,
       SUM(X.NAO) Total_Vendas_sem_Clientes,
       SUM(X.GERAL) Total_Vend_com_Clientes_inexistente,
       SUM(X.ASSOCIADA)  Total_Vendas_com_Clientes_assoc,
       SUM(X.ASSOCIADA_CPF_VALIDO) Total_Vendas_com_Clientes_assoc_cpf_ok
FROM
(
SELECT ISNULL((SELECT C.LOJA_NOME FROM LOJAS AS C WHERE C.loja_id = A.vend_loja_id),'') AS LOJA, 
       SUBSTRING(CONVERT(VARCHAR,A.vend_DT,111),1,7) AS ANOMES,
       CASE WHEN LTRIM(RTRIM(ISNULL(A.vend_clie_id,''))) = '' THEN 1 ELSE 0 END AS NAO,
       CASE WHEN LTRIM(RTRIM(ISNULL(A.vend_clie_id,''))) <> '' AND NOT EXISTS (SELECT 1 FROM CLIENTES AS B WHERE B.clie_id = A.vend_clie_id) THEN 1 ELSE 0 END AS GERAL,
       CASE WHEN LTRIM(RTRIM(ISNULL(A.vend_clie_id,''))) <> '' AND EXISTS (SELECT 1 FROM CLIENTES AS B WHERE B.clie_id = A.vend_clie_id) THEN 1 ELSE 0 END AS ASSOCIADA,
       CASE WHEN LTRIM(RTRIM(ISNULL(A.vend_clie_id,''))) <> '' AND EXISTS (SELECT 1 FROM CLIENTES AS B WHERE B.clie_id = A.vend_clie_id AND i9.dbo.fncValidateCPF(B.clie_cpf) = 'S') THEN 1 ELSE 0 END AS ASSOCIADA_CPF_VALIDO
FROM   VENDAS AS A
) AS X
GROUP  BY X.LOJA,X.ANOMES
ORDER  BY X.LOJA,X.ANOMES

Print '#  Distribuição valores de venda'
-- trocado por vend_vlr_pago por vend_vlr_final
SELECT vend_vlr_final,COUNT(*) FROM VENDAS GROUP  BY vend_vlr_final ORDER BY vend_vlr_final

 Print '#  Distribuição quantidades de itens da venda'
--ALterado da tabela de vendas para itens - ajuste da query abaixo

select qtd_itens,count(VEND_ID) QTD_VENDAS from (
SELECT  vend_id VEND_ID, count(iven_vend_id) qtd_itens
FROM VENDAS V , Itens_vendidos I 
WHERE V.vend_id=iven_vend_id 
group by vend_id ) qtd
group by qtd_itens
order by qtd_itens

Print '#  Distribuição valores de venda Brutos'
SELECT VEND_VLR_BRUTO,COUNT(*) FROM VENDAS GROUP  BY VEND_VLR_BRUTO ORDER BY VEND_VLR_BRUTO

Print '#  Distribuição valores de descontos em venda '
SELECT VEND_VLR_DESCONTO,COUNT(*) FROM VENDAS GROUP  BY VEND_VLR_DESCONTO ORDER BY VEND_VLR_DESCONTO

--Print '#  Distribuição valores de vendas em dinheiro '
-- CAMPO não existe na carga comentados os selects abaixo
--SELECT VEND_VLR_DINHEIRO,COUNT(*) FROM VENDAS GROUP  BY VEND_VLR_DINHEIRO ORDER BY VEND_VLR_DINHEIRO

--Print '#  Distribuição valores de vendas em cartao credito '
--SELECT VLR_CARTAO_CREDITO,COUNT(*) FROM VENDAS GROUP  BY VLR_CARTAO_CREDITO ORDER BY VLR_CARTAO_CREDITO

--Print '#  Distribuição valores de vendas em cartao debito '
--SELECT VLR_CARTAO_DEBITO,COUNT(*) FROM VENDAS GROUP  BY VLR_CARTAO_DEBITO ORDER BY VLR_CARTAO_DEBITO


--Print '#  Distribuição valores de vendas em cheque '
--SELECT VLR_CHEQUES,COUNT(*) FROM VENDAS GROUP  BY VLR_CHEQUES ORDER BY VLR_CHEQUES


--Print '#  Distribuição valores de vendas em vales '
--SELECT VLR_VALES,COUNT(*) FROM VENDAS GROUP  BY VLR_VALES ORDER BY VLR_VALES

--Print '#  Distribuição valores de vendas em outros '
--SELECT VLR_OUTROS,COUNT(*) FROM VENDAS GROUP  BY VLR_OUTROS ORDER BY VLR_OUTROS

print  'Distribuição de meios de pagamento '

SELECT VEND_MEIO_PGTO,COUNT(*) qtd FROM VENDAS GROUP  BY VEND_MEIO_PGTO ORDER BY VEND_MEIO_PGTO

Print '#  Distribuição de forma de pagamento '

SELECT VEND_FORMA_PGTO,COUNT(*) qtd FROM VENDAS GROUP  BY VEND_FORMA_PGTO ORDER BY VEND_FORMA_PGTO

Print '#  Quantidades de vendas em que o valor final não bate com valor bruto - descontos'

SELECT COUNT(*) FROM VENDAS WHERE VEND_VLR_FINAL <> (VEND_VLR_BRUTO - VEND_VLR_DESCONTO)

-- Não se aplica na animale
-- SELECT COUNT(*) FROM VENDAS WHERE VLR_PAGO <> (VLR_CARTAO_CRED + VLR_CARTAO_DEB + VLR_DINHEIRO + VLR_CHEQUES + VLR_VALES + VLR_OUTROS)

-- TROCADO IVEN_TOTAL_ITEM por (IVEN_VALOR-DESCONTO)*QTD 
-- OBS !!!  Validar !!!!
Print '#  Inconsistencia de valor entre valor de itens e valor bruto da nota'
SELECT COUNT(*)
FROM   VENDAS AS A
WHERE  VEND_VLR_BRUTO <> (SELECT SUM((B.IVEN_VALOR*IVEN_QTD))
                     FROM   ITENS_VENDIDOS AS B
                     WHERE  B.iven_vend_id = A.vend_id)

Print '#   Total Vendas por meio de pagamento '
--select x.cartao_CREDITO,
--       x.cartao_DEBITO,
--       x.dinheiro,
--       x.cheques,
--       X.VALES,
--       X.OUTROS,
--       count(*),
--       SUM(X.VLR_PAGO)
--from
--(
--select case when vlr_cartao_CRED <> 0 then 'S' else 'N' end as cartao_CREDITO,
--       case when vlr_cartao_deb <> 0 then 'S' else 'N' end as cartao_debito,
--       case when vlr_dinheiro <> 0 then 'S' else 'N' end as dinheiro,
--       case when vlr_cheques <> 0 then 'S' else 'N' end as cheques,
--       case when vlr_vales <> 0 then 'S' else 'N' end as vales,
--       case when vlr_outros <> 0 then 'S' else 'N' end as outros,
--       VLR_PAGO
--from   vendas
--) as x
--group  by x.cartao_CREDITO,
--          x.cartao_debito,
--          x.dinheiro,
--          x.cheques,
--          x.vales,
--          x.outros
--ORDER  by x.cartao_CREDITO,
--          x.cartao_debito,
--          x.dinheiro,
--          x.cheques,
--          x.vales,
--          x.outros

--- Como a base animale tem um modelo antigo foi utilizado a query abaixo : 
--  
select VEND_MEIO_PGTO , SUM(VEND_VLR_FINAL) Total_Valor_Final
from VENDAS
GROUP BY VEND_MEIO_PGTO

Print '#  Top Clientes por qtd Vendas'

select *
from
(
select a.vend_clie_id,b.clie_nome,count(8) as quant
from   vendas as a,
       clientes as b
where  a.vend_clie_id = b.clie_id
group  by a.vend_clie_id,b.clie_nome
) as x
where quant > 10 
order  by x.quant desc


print 'Resumo da associação de vendas por loja'

drop table  #resumo_assoc_venda 
go
create table #resumo_assoc_venda ( loja_id int, Loja_nome varchar(100),venda_nao_assoc int , venda_assoc int , venda_assoc_cpf_valido int , total_venda int , perc_assoc float ) 

insert into #resumo_assoc_venda ( loja_id , loja_nome, venda_nao_assoc )
select loja_id, loja_nome, count(*)
from vendas , lojas 
where vend_loja_id = loja_id
and vend_assoc = 'N'
group by  loja_id,loja_nome, vend_assoc
order by loja_nome

update #resumo_assoc_venda  set venda_assoc = qtd 
from #resumo_assoc_venda r  
inner join 
( select loja_id, loja_nome, count(*) qtd
from vendas , lojas 
where vend_loja_id = loja_id
and vend_assoc = 'S'
group by  loja_id,loja_nome, vend_assoc ) vendok 
 on ( r.loja_id = vendok.loja_id ) 

update #resumo_assoc_venda  set venda_assoc_cpf_valido = qtd 
from #resumo_assoc_venda r  
inner join 
( select  loja_id, loja_nome, count(*) qtd
from vendas , lojas , clientes 
where vend_loja_id = loja_id and 
vend_clie_id = clie_id
and vend_assoc = 'S'
and i9.dbo.fncValidateCPF(clie_cpf) ='S' 
group by  loja_id,loja_nome, vend_assoc ) vendok2 
 on ( r.loja_id = vendok2.loja_id ) 

 
update #resumo_assoc_venda  set total_venda = qtd 
from #resumo_assoc_venda r  
inner join 
( select loja_id, loja_nome, count(*) qtd
from vendas , lojas 
where vend_loja_id = loja_id
group by  loja_id,loja_nome ) vendok3 
 on ( r.loja_id = vendok3.loja_id ) 


 update #resumo_assoc_venda set perc_assoc=(venda_assoc*100)/total_venda

 select Loja_nome ,
		venda_nao_assoc  , 
		venda_assoc  , 
		venda_assoc_cpf_valido  , 
		total_venda  , perc_assoc   
from #resumo_assoc_venda


-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
------------------------------------- ITENS VENDIDOS ------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------


Print ' 

##########  Análise de Itens Vendidos ########## 

'


Print '#  Qtd Itens na tabela de itens '

SELECT COUNT(*) FROM ITENS_VENDIDOS

Print '#  Itens Vendidos fora da tabela de produtos'

SELECT COUNT(8)
FROM   ITENS_VENDIDOS AS A
WHERE  NOT EXISTS (SELECT 1
                   FROM   PRODUTOS AS B
                   WHERE  B.prod_id = A.iven_prod_id)

Print '#  Quantidade de itens por Operacoes '

SELECT case   iven_OPERACAO  when  1 then 'Venda' 
							 when  2 then 'Troca'  
	   END Operacao ,COUNT(8) Qtd
FROM   ITENS_VENDIDOS
GROUP  BY iven_OPERACAO
ORDER  BY iven_OPERACAO

Print '#  Distribuição Valores do Item'
SELECT iven_valor ,COUNT(8)
FROM   ITENS_VENDIDOS
GROUP  BY iven_valor
ORDER  BY iven_valor

Print '#  Distribuição Valores de desconto'
SELECT iven_DESCONTO VLR_DESCONTO,COUNT(8) qtd
FROM   ITENS_VENDIDOS
GROUP  BY iven_DESCONTO
ORDER  BY iven_DESCONTO

Print '#  Distribuição Quantidade de Itens'
SELECT iven_qtd Num_Itens,COUNT(8) qtd
FROM   ITENS_VENDIDOS
GROUP  BY iven_qtd
ORDER  BY iven_qtd

-- Não aderente a base animale
--SELECT VLR_TOT_ITEM,COUNT(8)
--FROM   ITENS_VENDIDOS
--GROUP  BY VLR_TOT_ITEM
--ORDER  BY VLR_TOT_ITEM



 --Não aderente a base animale
-- SELECT COUNT(*) FROM ITENS_VENDIDOS WHERE TOT_ITEM <> ((VLR_UNITARIO - VLR_DESCONTO) * QUANT)


-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
------------------------------------- MARCAÇÃO DE CLIENTES PARTICIPANTES ----------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

/*
UPDATE CLIENTES SET PARTICIPANTE = 'S'
UPDATE LOJAS    SET PARTICIPANTE = 'S'


--------- LISTA DE FUNCIONARIOS


update clientes
set    participante = 'N'
where  cpf in
()


--------- LOJAS NÃO PARTICIPANTES


update clientes
set    participante = 'N'
where  loja_id in ()

update lojas
set    participante = 'N'
where  loja_id in ()


--------- CPF CORINGA


delete clientes where cpf = ''


UPDATE A
SET    A.PARTICIPANTE = 'N'
FROM   CLIENTES AS A
WHERE  i9.dbo.fncValidateCPF(A.clie_cpf) = 'N'


-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
------------------------------------- MARCAÇÃO DE VENDAS VALIDAS ------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------


UPDATE VENDAS SET VALIDA = 'S'

UPDATE A
SET    A.VALIDA = 'N'
FROM   VENDAS AS A
WHERE  A.VALOR <= 0

UPDATE A
SET    A.VALIDA = 'N'
FROM   VENDAS AS A
WHERE  NOT EXISTS (SELECT 1
                   FROM   ITENS_VENDIDOS AS B
                   WHERE  B.COD_LOJA = A.COD_LOJA AND
                          B.DTATEND = A.DTATEND AND
                          B.NUM_ATD = B.NUM_ATD)

UPDATE A
SET    A.VALIDA = 'N'
FROM   VENDAS AS A
WHERE  NOT EXISTS (SELECT 1
                   FROM   LOJAS AS B
                   WHERE  B.COD_LOJA = A.COD_LOJA)

*/