-- =========================================================
-- PROCEDURE
-- =========================================================

DELIMITER $$

CREATE PROCEDURE sp_criar_pedido_completo (
    IN p_usuario INT,
    IN p_lavanderia INT,
    IN p_valor DECIMAL(10,2),
    IN p_taxa_entrega DECIMAL(10,2),
    IN p_tipo_pagamento ENUM('PIX','CARTAO'),
    IN p_cartao_id INT,
    IN p_tipo_cartao ENUM('DEBITO','CREDITO'),
    OUT p_pedido_id INT
)
BEGIN

    DECLARE v_pedido_id INT;
    DECLARE v_ordem_id INT;

    DECLARE v_valor_final DECIMAL(10,2);

    DECLARE v_cartao_existe INT DEFAULT 0;

    DECLARE v_taxa_entregador DECIMAL(10,2)
    DEFAULT 20.00;

    DECLARE v_taxa_app DECIMAL(10,2)
    DEFAULT 6.00;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SET v_valor_final =
        p_valor +
        p_taxa_entrega +
        v_taxa_entregador +
        v_taxa_app;

    INSERT INTO pedido (
        data,
        valor_total,
        taxa_entrega,
        taxa_entregador,
        taxa_app,
        tempo_estimado,
        fk_status_id,
        fk_lavanderia_id,
        fk_usuario_id
    )
    VALUES (
        NOW(),
        p_valor,
        p_taxa_entrega,
        v_taxa_entregador,
        v_taxa_app,
        '01:00:00',
        1,
        p_lavanderia,
        p_usuario
    );

    SET v_pedido_id = LAST_INSERT_ID();

    INSERT INTO ordem_pagamento (
        tipo_pagamento,
        valor,
        data_criacao,
        status,
        fk_pedido_id
    )
    VALUES (
        p_tipo_pagamento,
        v_valor_final,
        NOW(),
        'PENDENTE',
        v_pedido_id
    );

    SET v_ordem_id = LAST_INSERT_ID();

    IF p_tipo_pagamento = 'PIX' THEN

        INSERT INTO pix (
            chave_pix,
            data_expiracao,
            qr_code,
            status,
            fk_ordem_pagamento_id
        )
        VALUES (
            CONCAT('pix_', v_ordem_id),
            DATE_ADD(NOW(), INTERVAL 30 MINUTE),
            CONCAT('qr_', v_ordem_id),
            'PENDENTE',
            v_ordem_id
        );

    ELSEIF p_tipo_pagamento = 'CARTAO' THEN

        IF p_cartao_id IS NULL THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'Cartão obrigatório';

        END IF;

        SELECT COUNT(*)
        INTO v_cartao_existe
        FROM cartao
        WHERE cartao_id = p_cartao_id;

        IF v_cartao_existe = 0 THEN

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'Cartão não encontrado';

        END IF;

        INSERT INTO pagamento_cartao (
            token_utilizado,
            ultimos_digitos,
            tipo,
            fk_cartao_id,
            fk_ordem_pagamento_id
        )
        SELECT
            token_cartao,
            ultimos_digitos,
            p_tipo_cartao,
            cartao_id,
            v_ordem_id
        FROM cartao
        WHERE cartao_id = p_cartao_id;

    END IF;

    SET p_pedido_id = v_pedido_id;

    COMMIT;

END $$

DELIMITER ;