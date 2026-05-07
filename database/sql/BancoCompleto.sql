-- 1. CRIAÇÃO DO BANCO
CREATE DATABASE IF NOT EXISTS sempre_limpa_db;
USE sempre_limpa_db;

-- 2. TABELAS INDEPENDENTES (NÍVEL 1)
CREATE TABLE IF NOT EXISTS endereco (
    endereco_PK INT PRIMARY KEY AUTO_INCREMENT,
    cep VARCHAR(11) NOT NULL,
    uf VARCHAR(2) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    bairro VARCHAR(100) NOT NULL,
    logradouro VARCHAR(100) NOT NULL,
    numero VARCHAR(4) NOT NULL,
    complemento VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS endereco_lavanderia (
    endereco_lavanderia_PK INT PRIMARY KEY AUTO_INCREMENT,
    cep VARCHAR(8) NOT NULL,
    uf VARCHAR(2) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    bairro VARCHAR(100) NOT NULL,
    logradouro VARCHAR(100) NOT NULL,
    numero VARCHAR(4) NOT NULL,
    complemento VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS status (
    status_id INT PRIMARY KEY AUTO_INCREMENT,
    descricao VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS roupas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    quantidade INT NOT NULL,
    nome_peca VARCHAR(100) NOT NULL
);

-- 3. TABELAS DEPENDENTES (NÍVEL 2 - Entidades com FK para o Nível 1)
CREATE TABLE IF NOT EXISTS usuario (
    usuario_id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    e_mail VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(11),
    cpf VARCHAR(11) UNIQUE,
    rne VARCHAR(9),
    fk_endereco INT,
    senha VARCHAR(12) NOT NULL,
    CONSTRAINT fk_usuario_endereco FOREIGN KEY (fk_endereco) REFERENCES endereco(endereco_PK)
);

CREATE TABLE IF NOT EXISTS lavanderia (
    lavanderia_id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(300),
    cnpj VARCHAR(14) UNIQUE NOT NULL,
    tempo_padrao_lavagem TIME,
    tempo_secagem TIME,
    logo VARCHAR(255),
    e_mail VARCHAR(255),
    telefone VARCHAR(11),
    fk_endereco_lavanderia INT,
    CONSTRAINT fk_lavanderia_endereco_lavanderia FOREIGN KEY (fk_endereco_lavanderia) REFERENCES endereco_lavanderia(endereco_lavanderia_PK)
);

-- 4. TABELAS DE FLUXO (NÍVEL 3 - Dependem de Usuário/Lavanderia/Status)
CREATE TABLE IF NOT EXISTS cartao (
    cartao_id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT,
    bandeira VARCHAR(20),
    validade VARCHAR(4),
    token_cartao VARCHAR(255),
    ultimos_digitos VARCHAR(4),
    CONSTRAINT fk_cartao_usuario FOREIGN KEY (usuario_id) REFERENCES usuario(usuario_id)
);

CREATE TABLE IF NOT EXISTS favoritos (
    favoritos_id INT PRIMARY KEY AUTO_INCREMENT,
    fk_usuario_id INT NOT NULL,
    fk_lavanderia_id INT NOT NULL,
    CONSTRAINT fk_favoritos_usuario FOREIGN KEY (fk_usuario_id) REFERENCES usuario(usuario_id),
    CONSTRAINT fk_favoritos_lavanderia FOREIGN KEY (fk_lavanderia_id) REFERENCES lavanderia(lavanderia_id)
);

CREATE TABLE IF NOT EXISTS avaliacao (
    avaliacao_id INT PRIMARY KEY AUTO_INCREMENT,
    nota INT CHECK (nota BETWEEN 1 AND 5),
    data DATETIME DEFAULT CURRENT_TIMESTAMP,
    comentario VARCHAR(255),
    fk_usuario_id INT,
    fk_lavanderia_id INT,
    CONSTRAINT fk_avaliacao_usuario FOREIGN KEY (fk_usuario_id) REFERENCES usuario(usuario_id),
    CONSTRAINT fk_avaliacao_lavanderia FOREIGN KEY (fk_lavanderia_id) REFERENCES lavanderia(lavanderia_id)
);

CREATE TABLE IF NOT EXISTS pedido (
    pedido_id INT PRIMARY KEY AUTO_INCREMENT,
    data DATETIME DEFAULT CURRENT_TIMESTAMP,
    valor_total DECIMAL(10,2),
    taxa_entrega DECIMAL(10,2),
    taxa_entregador DECIMAL(10,2),
    tempo_estimado TIME,
    fk_status_id INT,
    fk_lavanderia_id INT,
    fk_usuario_id INT,
    CONSTRAINT fk_pedido_status FOREIGN KEY (fk_status_id) REFERENCES status(status_id),
    CONSTRAINT fk_pedido_lavanderia FOREIGN KEY (fk_lavanderia_id) REFERENCES lavanderia(lavanderia_id),
    CONSTRAINT fk_pedido_usuario FOREIGN KEY (fk_usuario_id) REFERENCES usuario(usuario_id)
);

-- 5. TABELAS DE DETALHE E PAGAMENTO (NÍVEL 4 - Dependem de Pedido/Cartão)
CREATE TABLE IF NOT EXISTS cesto (
    cesto_id INT PRIMARY KEY AUTO_INCREMENT,
    peso_estimado DECIMAL(5,2),
    secagem ENUM('SIM','NAO') DEFAULT 'NAO',
    tipo_lavagem ENUM('NORMAL','PESADA') DEFAULT 'NORMAL',
    fk_pedido_id INT,
    CONSTRAINT fk_cesto_pedido FOREIGN KEY (fk_pedido_id) REFERENCES pedido(pedido_id)
);

CREATE TABLE IF NOT EXISTS recebe (
    fk_cesto_id INT,
    fk_roupas_id INT,
    PRIMARY KEY (fk_cesto_id, fk_roupas_id),
    CONSTRAINT fk_recebe_cesto FOREIGN KEY (fk_cesto_id) REFERENCES cesto(cesto_id),
    CONSTRAINT fk_recebe_roupas FOREIGN KEY (fk_roupas_id) REFERENCES roupas(id)
);

CREATE TABLE IF NOT EXISTS ordem_pagamento (
    ordem_pagamento_id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_pagamento ENUM('PIX','CARTAO') NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    data_criacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('PAGO','PENDENTE','CANCELADO') DEFAULT 'PENDENTE',
    fk_pedido_id INT,
    CONSTRAINT fk_ordem_pagamento_pedido FOREIGN KEY (fk_pedido_id) REFERENCES pedido(pedido_id)
);

CREATE TABLE IF NOT EXISTS pagamento_cartao (
    pagamento_cartao_id INT PRIMARY KEY AUTO_INCREMENT,
    token_utilizado VARCHAR(255),
    ultimos_digitos VARCHAR(4),
    tipo ENUM('DEBITO','CREDITO'),
    fk_cartao_id INT,
    fk_ordem_pagamento_id INT,
    CONSTRAINT fk_pagamento_cartao_cartao FOREIGN KEY (fk_cartao_id) REFERENCES cartao(cartao_id),
    CONSTRAINT fk_pagamento_cartao_ordem_pagamento FOREIGN KEY (fk_ordem_pagamento_id) REFERENCES ordem_pagamento(ordem_pagamento_id)
);

CREATE TABLE IF NOT EXISTS pix (
    pix_id INT PRIMARY KEY AUTO_INCREMENT,
    chave_pix VARCHAR(255),
    data_expiracao DATETIME,
    qr_code VARCHAR(255),
    status ENUM('PAGO','PENDENTE','EXPIRADO') DEFAULT 'PENDENTE',
    fk_ordem_pagamento_id INT,
    CONSTRAINT fk_pix_ordem_pagamento FOREIGN KEY (fk_ordem_pagamento_id) REFERENCES ordem_pagamento(ordem_pagamento_id)
);

-- 1. Endereços (Base para tudo)
INSERT IGNORE INTO endereco VALUES (1,'06657300','SP','Itapevi','Rosemary','Rua serra do paracaima','1374',NULL);

INSERT IGNORE INTO endereco_lavanderia (endereco_lavanderia_PK, cep, uf, cidade, bairro, logradouro, numero, complemento) VALUES 
(1, '01001000', 'SP', 'São Paulo', 'Centro', 'Praça da Sé', '100', 'Sala 1'),
(2, '04538132', 'SP', 'São Paulo', 'Itaim Bibi', 'Av. Brigadeiro Faria Lima', '3477', 'Térreo'),
(3, '01310100', 'SP', 'São Paulo', 'Bela Vista', 'Av. Paulista', '1500', 'Loja A'),
(4, '20040002', 'RJ', 'Rio de Janeiro', 'Centro', 'Av. Rio Branco', '120', NULL),
(5, '30140010', 'MG', 'Belo Horizonte', 'Savassi', 'Rua Pernambuco', '700', 'Bloco B');

-- 2. Entidades Principais
INSERT IGNORE INTO usuario VALUES (1,'Weslei','wees@email.com','11984106174','57030864859',NULL,1,'weslei123');
INSERT IGNORE INTO usuario VALUES (2,'Maria Silva','maria@email.com','11987654321','12345678901',NULL,1,'maria123');
INSERT IGNORE INTO usuario VALUES (3,'João Santos','joao@email.com','11991234567','98765432100',NULL,1,'joao123');
INSERT IGNORE INTO usuario VALUES (4,'Ana Souza','ana@email.com','11999887766','45678912300',NULL,1,'ana123');

REPLACE INTO lavanderia (lavanderia_id, nome, descricao, cnpj, tempo_padrao_lavagem, tempo_secagem, logo, e_mail, telefone, fk_endereco_lavanderia) VALUES 
(2, '5asec', NULL, '04078995000245', NULL, NULL, 'https://...s', '5asec@test.com', '11999999998', 1),
(3, 'white Bubble', NULL, '12345678000199', NULL, NULL, 'https://via.placeholder.com/150', 'bubble@test.com', '11988888888', 2),
(4, 'Super Clean', NULL, '98765432000188', NULL, NULL, 'https://via.placeholder.com/150', 'superclean@test.com', '11977777777', 3),
(5, 'Lavanderia Rápida', NULL, '11222333000155', NULL, NULL, 'https://via.placeholder.com/150', 'rapida@test.com', '11966666666', 4),
(6, 'Premium Clean', 'Especializada em lavagem delicada e roupas finas', '99887766000144', '01:20:00', '00:50:00', 'https://via.placeholder.com/150', 'premiumclean@test.com', '11993334444', 5);

-- 3. Status e Feedbacks
INSERT IGNORE INTO status (status_id, descricao) VALUES (1, 'PENDENTE'), (2, 'PAGO'), (3, 'EM_ANDAMENTO'), (4, 'FINALIZADO'), (5, 'CANCELADO');

INSERT INTO avaliacao VALUES (3, 5, NOW(), 'Nota 10', 1, 2);
INSERT INTO avaliacao VALUES (4, 4, NOW(), 'Muito boa lavanderia', 1, 3);
INSERT INTO avaliacao VALUES (5, 3, NOW(), 'Serviço ok, pode melhorar', 2, 4);

-- 4. Pedido e Cartão (Para a Procedure funcionar depois)
INSERT INTO pedido (pedido_id, data, valor_total, taxa_entrega, taxa_entregador, tempo_estimado, fk_status_id, fk_lavanderia_id, fk_usuario_id)
VALUES (1, NOW(), 60, 10, 0, '01:00:00', 1, 2, 1);

INSERT INTO cartao (cartao_id, usuario_id, bandeira, validade, token_cartao, ultimos_digitos)
VALUES (1, 1, 'VISA', '1228', 'token_exemplo_abc123', '3456');

-- Views

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

-- Triggers

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

-- Procedures

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
    DECLARE v_cartao_existe INT DEFAULT 0;

    -- Handler para erro: faz Rollback em qualquer falha
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- 1. CÁLCULO DE VALORES
    -- Definindo taxa fixa do entregador
    SET @taxa_entregador = 20.00;
    -- Valor final = serviço + entrega + entregador
    SET v_valor_final = p_valor + p_taxa_entrega + @taxa_entregador;

    -- 2. CRIAR O PEDIDO
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
        1, -- Status PENDENTE
        p_lavanderia,
        p_usuario
    );

    SET v_pedido_id = LAST_INSERT_ID();

    -- 3. CRIAR ORDEM DE PAGAMENTO
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

    -- 4. PROCESSAR MÉTODO DE PAGAMENTO ESPECÍFICO
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

        -- Verificação do cartão movida para cá (Lógica de Negócio)
        IF p_cartao_id IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ID do Cartão é obrigatório para pagamento com CARTAO';
        END IF;

        SELECT COUNT(*) INTO v_cartao_existe FROM cartao WHERE cartao_id = p_cartao_id;

        IF v_cartao_existe = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cartão não encontrado no banco de dados';
        END IF;

        -- Registra o pagamento com os dados do cartão
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

    -- 5. RETORNO DO ID PARA O BACKEND
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