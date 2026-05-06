/* Stored Procedure criação de pedido(COM TRENSAÇÃO) */

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
	DECLARE v_cartao_existe INT;


    -- erro rollback
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
        SELECT COUNT(*)
    INTO v_cartao_existe
    FROM cartao
    WHERE cartao_id = p_cartao_id;
    
    IF v_cartao_existe = 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cartão não encontrado';
	END IF;

    START TRANSACTION;

    -- taxa fixa do entregador
    SET @taxa_entregador = 20;

    -- valor final correto
    SET v_valor_final = p_valor + p_taxa_entrega + @taxa_entregador;

    -- 1. CRIAR PEDIDO
    INSERT INTO pedido (
        data,
        valor_total,
        taxa_entrega,
        taxa_entregador,
        tempo_estimado,
        fk_status_id,
        fk_lavanderia_id,
        fk_usuario_id
    )
    VALUES (
        NOW(),
        p_valor,
        p_taxa_entrega,
        @taxa_entregador,
        '01:00:00',
        1,
        p_lavanderia,
        p_usuario
    );

    SET v_pedido_id = LAST_INSERT_ID();

    -- 2. ORDEM DE PAGAMENTO (usa valor FINAL do pedido)
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

    -- 3. PAGAMENTO
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
            SET MESSAGE_TEXT = 'Cartão é obrigatório para pagamento CARTAO';
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

    -- 4. RETORNO
    SET p_pedido_id = v_pedido_id;

    COMMIT;

END $$

DELIMITER ;

CALL sp_criar_pedido_completo(
    4,              -- usuario_id
    4,              -- lavanderia_id
    50.00,          -- valor do serviço (lavagem)
    10.00,          -- taxa entrega
    'PIX',          -- tipo pagamento
    NULL,           -- cartao_id (não usa)
    NULL,           -- tipo cartao
    @pedido_id
);

/* Stored Procedure favo */