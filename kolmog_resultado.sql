CREATE TABLE `resultado` (
  `id` int(11) DEFAULT NULL,
  `valor` float(10,4) DEFAULT NULL,
  `esper` float(10,4) DEFAULT NULL,
  `desvio` float(3,2) DEFAULT NULL,
  `z_val` float(10,5) DEFAULT NULL,
  `dif` float(10,4) DEFAULT NULL,
  `dif_1` float(10,4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


DELIMITER $$

CREATE PROCEDURE `kolmog`(
IN coluna VARCHAR(100),
IN tabela1 VARCHAR(100),
OUT resp VARCHAR(100)
)
BEGIN

DECLARE esperado, esperado_1, z_value, diferenáa, diferenáa_1 FLOAT(10,7);
DECLARE desv FLOAT(3,2);
DECLARE resposta, p_value FLOAT(5,4);
SET @cont = 1;
SET @contagem = 0;

IF (SELECT COUNT(*) FROM resultado) > 0
THEN
DELETE FROM resultado WHERE id > 0;
ELSE
SELECT * FROM resultado;
END IF;

DROP TABLE IF EXISTS tabela;

SET @sele = CONCAT('CREATE TABLE tabela SELECT @contagem:= @contagem + 1 AS id, ',coluna,' as Valor FROM ',tabela1,' ORDER BY ', coluna);
PREPARE stmt FROM @sele;
EXECUTE stmt; 
DEALLOCATE PREPARE stmt;

SELECT STD(Valor) INTO @desvio FROM tabela;
SELECT AVG(Valor) INTO @media FROM tabela;
SELECT COUNT(Valor) INTO @dimen FROM tabela;

WHILE @cont  <= (SELECT COUNT(*) FROM tabela)
DO
SELECT Valor INTO @linha FROM tabela WHERE id = @cont;

SET esperado = @cont  / @dimen;
SET desv = (@linha - @media) / @desvio;

IF desv > (SELECT MAX(z) FROM z_test) 
THEN
SET z_value = 0.999949878;
ELSEIF desv < (SELECT MIN(z) FROM z_test) 
THEN
SET z_value = 0.000050122;
ELSE
SET z_value = (SELECT value FROM z_test WHERE z = desv);
END IF;

SET diferenáa  = ABS(z_value - esperado);

IF @cont  = 1
THEN
SET diferenáa_1 = z_value;
ELSE
SET esperado_1 = (SELECT esper FROM resultado WHERE id = (@cont  - 1));
SET diferenáa_1 = ABS(z_value - esperado_1);
END IF;

INSERT INTO resultado(id, valor, esper, desvio, z_val, dif, dif_1) VALUES(@cont , @linha, esperado, desv, z_value, diferenáa, diferenáa_1);

SET @cont  = @cont  + 1;
END WHILE;

IF (SELECT MAX(dif) FROM resultado) > (SELECT MAX(dif_1) FROM resultado)
THEN
SET resposta = (SELECT MAX(dif) FROM resultado);
ELSE
SET resposta = (SELECT MAX(dif_1) FROM resultado);
END IF;

IF @dimen > 35
THEN 
SET p_value = (1.36 / SQRT(@dimen));
ELSE
SET p_value = (SELECT c_value FROM critic WHERE n = @dimen);
END IF;

IF resposta > p_value
THEN
SET @normal = 'Distribuiá∆o n∆o normal';
ELSE
SET @normal = 'Distribuiá∆o normal';
END IF;

SELECT CONCAT('D:',resposta,', p_value:',p_value,', Resultado:',@normal) INTO resp;

DROP TABLE IF EXISTS tabela;

END $$
DELIMITER ;