create database sempre_limpa_db;

use sempre_limpa_db;

CREATE TABLE endereco (
    endereco_PK INT PRIMARY KEY,
    cep VARCHAR(8) NOT NULL,
    uf VARCHAR(2) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    bairro VARCHAR(100) NOT NULL,
    logradouro VARCHAR(100) NOT NULL,
    numero VARCHAR(4) NOT NULL,
    complemento VARCHAR(100)
);

CREATE TABLE endereco_lavanderia (
	endereco_lavanderia_PK INT PRIMARY KEY,
    cep VARCHAR(8) NOT NULL,
    uf VARCHAR(2) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    bairro VARCHAR(100) NOT NULL,
    logradouro varchar(100) NOT NULL,
    numero VARCHAR(4) NOT NULL,
    complemento VARCHAR(100)
    );

CREATE TABLE usuario (
    usuario_id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    e_mail VARCHAR(100) NOT NULL,
    telefone VARCHAR(11) NOT NULL,
    cpf VARCHAR(11) NOT NULL UNIQUE,
    rne VARCHAR(9),
    senha varchar(12) NOT NULL,
    fk_endereco INT NOT NULL,
    CONSTRAINT fk_usuario_endereco
        FOREIGN KEY (fk_endereco)
        REFERENCES endereco(endereco_PK)
        ON DELETE CASCADE
);

CREATE TABLE status (
    status_id INT PRIMARY KEY,
    descricao VARCHAR(50) NOT NULL
);

CREATE TABLE lavanderia (
    lavanderia_id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(300),
    cnpj VARCHAR(14) NOT NULL UNIQUE,
    tempo_padrao_lavagem TIME,
    tempo_secagem TIME,
    logo VARCHAR(255) NOT NULL,
    e_mail VARCHAR(255) NOT NULL,
    telefone VARCHAR(11) NOT NULL
);

ALTER TABLE pedido 
MODIFY pedido_id INT NOT NULL AUTO_INCREMENT;

ALTER TABLE cesto 
DROP FOREIGN KEY fk_cesto_pedido;

CREATE TABLE pedido (
    pedido_id INT PRIMARY KEY,
    data DATETIME NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL,
    taxa_entrega DECIMAL(10,2) NOT NULL,
    taxa_entregador DECIMAL(10,2) NOT NULL,
    tempo_estimado TIME NOT NULL,
    fk_status_id INT NOT NULL,
    fk_lavanderia_id INT NOT NULL,
    CONSTRAINT fk_pedido_status
        FOREIGN KEY (fk_status_id)
        REFERENCES status(status_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_pedido_lavanderia
        FOREIGN KEY (fk_lavanderia_id)
        REFERENCES lavanderia(lavanderia_id)
        ON DELETE CASCADE
);

ALTER TABLE pedido 
ADD COLUMN fk_usuario_id INT NOT NULL;

ALTER TABLE pedido
ADD CONSTRAINT fk_pedido_usuario
FOREIGN KEY (fk_usuario_id)
REFERENCES usuario(usuario_id)
ON DELETE CASCADE;

CREATE TABLE cesto (
    cesto_id INT PRIMARY KEY,
    peso_estimado DECIMAL(5,2) NOT NULL,
    secagem ENUM('SIM', 'NAO') NOT NULL,
    tipo_lavagem ENUM('NORMAL', 'PESADA') NOT NULL,
    fk_pedido_id INT NOT NULL,
    CONSTRAINT fk_cesto_pedido
        FOREIGN KEY (fk_pedido_id)
        REFERENCES pedido(pedido_id)
        ON DELETE CASCADE
);

CREATE TABLE ordem_pagamento (
    ordem_pagamento_id INT PRIMARY KEY,
    tipo_pagamento ENUM('PIX', 'CARTAO'),
    valor DECIMAL(10,2) NOT NULL,
    data_criacao DATETIME NOT NULL,
    status ENUM('PAGO', 'PENDENTE', 'CANCELADO') NOT NULL,
    fk_pedido_id INT NOT NULL,
    CONSTRAINT fk_ordem_pedido
        FOREIGN KEY (fk_pedido_id)
        REFERENCES pedido(pedido_id)
        ON DELETE CASCADE
);

CREATE TABLE cartao (
    cartao_id INT PRIMARY KEY,
    usuario_id INT NOT NULL,
    bandeira VARCHAR(20) NOT NULL,
    validade VARCHAR(4) NOT NULL,
    token_cartao VARCHAR(255) NOT NULL,
    ultimos_digitos VARCHAR(4) NOT NULL,
    CONSTRAINT fk_cartao_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuario(usuario_id)
        ON DELETE CASCADE
);

CREATE TABLE pagamento_cartao (
    pagamento_cartao_id INT PRIMARY KEY,
    token_utilizado VARCHAR(255) NOT NULL,
    ultimos_digitos VARCHAR(4) NOT NULL,
    tipo ENUM('DEBITO', 'CREDITO') NOT NULL,
    fk_cartao_id INT NOT NULL,
    fk_ordem_pagamento_id INT NOT NULL,
    CONSTRAINT fk_pagamento_cartao_cartao
        FOREIGN KEY (fk_cartao_id)
        REFERENCES cartao(cartao_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_pagamento_cartao_ordem
        FOREIGN KEY (fk_ordem_pagamento_id)
        REFERENCES ordem_pagamento(ordem_pagamento_id)
        ON DELETE CASCADE
);

CREATE TABLE pix (
    pix_id INT PRIMARY KEY,
    chave_pix VARCHAR(255) NOT NULL,
    data_expiracao DATETIME NOT NULL,
    qr_code VARCHAR(255) NOT NULL,
    status ENUM('PAGO', 'PENDENTE', 'EXPIRADO') NOT NULL,
    fk_ordem_pagamento_id INT NOT NULL,
    CONSTRAINT fk_pix_ordem
        FOREIGN KEY (fk_ordem_pagamento_id)
        REFERENCES ordem_pagamento(ordem_pagamento_id)
        ON DELETE CASCADE
);

CREATE TABLE avaliacao (
    avaliacao_id INT PRIMARY KEY,
    nota INT NOT NULL,
    data DATETIME NOT NULL,
    comentario VARCHAR(255) NOT NULL,
    fk_usuario_id INT NOT NULL,
    fk_lavanderia_id INT NOT NULL,
    CONSTRAINT fk_avaliacao_usuario
        FOREIGN KEY (fk_usuario_id)
        REFERENCES usuario(usuario_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_avaliacao_lavanderia
        FOREIGN KEY (fk_lavanderia_id)
        REFERENCES lavanderia(lavanderia_id)
        ON DELETE CASCADE
);

CREATE TABLE roupas (
    id INT PRIMARY KEY,
    quantidade INT NOT NULL,
    nome_peca VARCHAR(100) NOT NULL
);

CREATE TABLE recebe (
    fk_cesto_id INT NOT NULL,
    fk_roupas_id INT NOT NULL,
    PRIMARY KEY (fk_cesto_id, fk_roupas_id),
    CONSTRAINT fk_recebe_cesto
        FOREIGN KEY (fk_cesto_id)
        REFERENCES cesto(cesto_id),
    CONSTRAINT fk_recebe_roupas
        FOREIGN KEY (fk_roupas_id)
        REFERENCES roupas(id)
);

CREATE TABLE favoritos (
    favoritos_id INT PRIMARY KEY,
    fk_usuario_id INT NOT NULL,
    fk_lavanderia_id INT NOT NULL,
    CONSTRAINT fk_favoritos_usuario
        FOREIGN KEY (fk_usuario_id)
        REFERENCES usuario(usuario_id),
    CONSTRAINT fk_favoritos_lavanderia
        FOREIGN KEY (fk_lavanderia_id)
        REFERENCES lavanderia(lavanderia_id)
);

/* Insert de endereços */
INSERT INTO endereco VALUES (1,'06657300','SP','Itapevi','Rosemary','Rua serra do paracaima','1374',NULL);

/* Insert de usuarios */
INSERT INTO usuario VALUES (1,'Weslei','wees@email.com','11984106174','57030864859',NULL,1,'weslei123');
INSERT INTO usuario VALUES (2,'Maria Silva','maria@email.com','11987654321','12345678901',NULL,1,'maria123');
INSERT INTO usuario VALUES (3,'João Santos','joao@email.com','11991234567','98765432100',NULL,1,'joao123');
INSERT INTO usuario VALUES (4,'Ana Souza','ana@email.com','11999887766','45678912300',NULL,1,'ana123');

/* Insert de lavanderias */
INSERT INTO lavanderia VALUES (2,'5asec',NULL,'04078995000245',NULL,NULL,'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQnZyjlH6tukWrKpXSTSKNJW5ZFN-ef09tPyA&s','5asec@test.com','11999999998');
INSERT INTO lavanderia VALUES (3,'white Bubble',NULL,'12345678000199',NULL,NULL,'https://via.placeholder.com/150','bubble@test.com','11988888888');
INSERT INTO lavanderia VALUES (4,'Super Clean',NULL,'98765432000188',NULL,NULL,'https://via.placeholder.com/150','superclean@test.com','11977777777');
INSERT INTO lavanderia VALUES (5,'Lavanderia Rápida',NULL,'11222333000155',NULL,NULL,'https://via.placeholder.com/150','rapida@test.com','11966666666');
INSERT INTO lavanderia VALUES (6, 'Premium Clean', 'Especializada em lavagem delicada e roupas finas', '99887766000144', '01:20:00', '00:50:00', 'https://via.placeholder.com/150', 'premiumclean@test.com', '11993334444');

/* Insert de avaliação das lavanderias */
INSERT INTO avaliacao VALUES (3, 5, NOW(), 'Nota 10', 1, 1);
INSERT INTO avaliacao VALUES (4, 4, NOW(), 'Muito boa lavanderia', 1, 3);
INSERT INTO avaliacao VALUES (5, 3, NOW(), 'Serviço ok, pode melhorar', 2, 4);
INSERT INTO avaliacao VALUES (6, 5, NOW(), 'Excelente atendimento!', 3, 5);
INSERT INTO avaliacao VALUES (7, 5, NOW(), 'Ótimo serviço!', 1, 4);
INSERT INTO avaliacao VALUES (8, 4, NOW(), 'Gostei bastante', 2, 5);
INSERT INTO avaliacao VALUES (9, 3, NOW(), 'Serviço razoável', 3, 3);

/* Para mostrar a estrutura da tabela */
desc lavanderia;

/* Para deletar um dado */
delete from avaliacao
where avaliacao_id = 2;

/* Para mostrar a tabela preenchida */
select * from lavanderia;
select * from avaliacao;

/* Para atualizar um insert de dado já feito */
UPDATE lavanderia
SET 
    nome = 'White Bubble',
    cnpj = '12345678000199',
    logo = 'https://via.placeholder.com/150',
    e_mail = 'bubble@test.com',
    telefone = '11966666666'
WHERE lavanderia_id = 3;

/* Insert de status */
INSERT INTO status (status_id, descricao) VALUES
(1, 'PENDENTE'),
(2, 'PAGO'),
(3, 'EM_ANDAMENTO'),
(4, 'FINALIZADO'),
(5, 'CANCELADO');

/* Insert de pedido */
INSERT INTO pedido (
    data, valor_total, taxa_entrega, taxa_entregador,
    tempo_estimado, fk_status_id, fk_lavanderia_id, fk_usuario_id
)
VALUES (
    NOW(), 60, 10, 0, '01:00:00', 1, 2, 1
);

/* Insert de cartão */
INSERT INTO cartao (
    usuario_id, bandeira, validade, token_cartao, ultimos_digitos
)
VALUES (
    1, 'VISA', '1228', 'token_exemplo_abc123', '3456'
);

INSERT INTO pagamento_cartao (
    token_utilizado,
    ultimos_digitos,
    tipo,
    fk_cartao_id,
    fk_ordem_pagamento_id
)
VALUES ('x', '1228', 'CREDITO', 1, 1);

SELECT * FROM pedido;

SELECT * FROM cartao;

SELECT * FROM ordem_pagamento;

/* Limitar avalição dentre 1 e 5 */
DELIMITER $$

CREATE TRIGGER trg_valida_nota
BEFORE INSERT ON avaliacao
FOR EACH ROW
BEGIN
    IF NEW.nota < 1 OR NEW.nota > 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nota deve ser entre 1 e 5';
    END IF;
END $$

DELIMITER ;

/* View de avaliações das lavanderias */
CREATE VIEW vw_avaliacoes AS
SELECT 
    l.nome AS lavanderia,
    u.nome AS usuario,
    a.nota,
    a.comentario,
    a.data
FROM avaliacao a
JOIN usuario u ON u.usuario_id = a.fk_usuario_id
JOIN lavanderia l ON l.lavanderia_id = a.fk_lavanderia_id;

SELECT * FROM vw_avaliacoes;

/* View de média de avaliações das lavanderias */
CREATE VIEW vw_media_lavanderia AS
SELECT 
    l.lavanderia_id,
    l.nome,
    ROUND(AVG(a.nota),1) AS media_avaliacao
FROM lavanderia l
LEFT JOIN avaliacao a 
    ON a.fk_lavanderia_id = l.lavanderia_id
GROUP BY l.lavanderia_id, l.nome;

SELECT * FROM vw_media_lavanderia ORDER BY media_avaliacao DESC;

/* View para mostrar endereço do usuário no perfil */
CREATE VIEW vw_usuario_endereco_perfil AS
SELECT 
    u.usuario_id,
    u.nome,
    CONCAT(
		COALESCE(e.logradouro, ''),', ',
		COALESCE(e.numero, ''),' - ',
        COALESCE(e.bairro, ''),', ',
        COALESCE(e.cidade, ''),' - ',
        COALESCE(e.uf, ''), ' - CEP: ',
        COALESCE(e.cep, ''),
		COALESCE(e.complemento, '')
        ) AS endereco_completo
FROM usuario u
JOIN endereco e 
    ON e.endereco_PK = u.fk_endereco;
    
/* View para mostrar pedidos completo(histórico) */
CREATE VIEW vw_pedido_completo AS
SELECT 
    p.pedido_id,
    u.nome AS usuario,
    l.nome AS lavanderia,
    p.valor_total,
    p.taxa_entrega,
    p.tempo_estimado,
    s.descricao AS status,
    p.data
FROM pedido p
JOIN usuario u ON u.usuario_id = p.fk_usuario_id
JOIN lavanderia l ON l.lavanderia_id = p.fk_lavanderia_id
JOIN status s ON s.status_id = p.fk_status_id;

SELECT * FROM vw_pedido_completo;

/* View para mostrar pagamento detalhado(histórico) */
CREATE VIEW vw_pagamento_detalhado AS
SELECT 
    op.ordem_pagamento_id,
    op.tipo_pagamento,
    op.valor,
    op.status,
    p.pedido_id,
    
    pc.tipo AS tipo_cartao,
    px.status AS status_pix
    
FROM ordem_pagamento op
LEFT JOIN pagamento_cartao pc 
    ON pc.fk_ordem_pagamento_id = op.ordem_pagamento_id
LEFT JOIN pix px 
    ON px.fk_ordem_pagamento_id = op.ordem_pagamento_id
JOIN pedido p 
    ON p.pedido_id = op.fk_pedido_id;
    
/* View para mostrar o cesto e roupas */
CREATE VIEW vw_cesto_roupas AS
SELECT 
    c.cesto_id,
    r.nome_peca,
    re.fk_roupas_id,
    r.quantidade
FROM cesto c
JOIN recebe re ON re.fk_cesto_id = c.cesto_id
JOIN roupas r ON r.id = re.fk_roupas_id;

/* View para mostrar lavanderias favoritadas(filtro) */
CREATE VIEW vw_favoritos_usuario AS
SELECT 
    u.nome AS usuario,
    l.nome AS lavanderia
FROM favoritos f
JOIN usuario u ON u.usuario_id = f.fk_usuario_id
JOIN lavanderia l ON l.lavanderia_id = f.fk_lavanderia_id;

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