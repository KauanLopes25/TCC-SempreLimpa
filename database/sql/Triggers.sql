-- =========================================================
-- TRIGGERS
-- =========================================================

DELIMITER $$

CREATE TRIGGER trg_valida_nota
BEFORE INSERT ON avaliacao
FOR EACH ROW
BEGIN

    IF NEW.nota < 1 OR NEW.nota > 5 THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Nota deve ser entre 1 e 5';

    END IF;

END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_valor_total_pedido
BEFORE INSERT ON pedido
FOR EACH ROW
BEGIN

    SET NEW.valor_total =
        IFNULL(NEW.valor_total,0) +
        IFNULL(NEW.taxa_entrega,0) +
        IFNULL(NEW.taxa_entregador,0) +
        IFNULL(NEW.taxa_app,0);

END $$

DELIMITER ;
