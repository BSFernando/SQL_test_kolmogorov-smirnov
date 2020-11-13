# SQL_test_kolmogorov-smirnov

Importar arquivos SQL:
mysql -u 'user name' -p 'database_name' <.../z_critical_value.sql
mysql -u 'user name' -p 'database_name' <.../kolmog_resultado.sql
mysql -u 'user name' -p 'database_name' <.../tabela_teste_lamna.sql

Após importar z_critical_value.sql e kolmog_resultado.sql faça o teste ks através do comando 'CALL kolmog("nome_coluna", "nome_tabela", @distr);'.

Ao chamar a variavel @distr 'SELECT @distr;', é retornado o D-critico, p-value (nível de significância 0.05) e resultado do teste.

Exemplo a partir de dados que não seguem uma distribuição normal (tabela_teste_lamna.sql).

<img src="https://github.com/BSFernando/SQL_test_kolmogorov-smirnov/blob/main/ks_teste.png" alt="alt text" width="600px">
